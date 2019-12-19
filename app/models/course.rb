# == Schema Information
#
# Table name: course
#
#  accrediting_provider_code :text
#  accrediting_provider_id   :integer
#  age_range_in_years        :string
#  applications_open_from    :date
#  changed_at                :datetime         not null
#  course_code               :text
#  created_at                :datetime         not null
#  discarded_at              :datetime
#  english                   :integer
#  id                        :integer          not null, primary key
#  is_send                   :boolean          default(FALSE)
#  level                     :string
#  maths                     :integer
#  modular                   :text
#  name                      :text
#  profpost_flag             :text
#  program_type              :text
#  provider_id               :integer          default(0), not null
#  qualification             :integer          not null
#  science                   :integer
#  start_date                :datetime
#  study_mode                :text
#  updated_at                :datetime         not null
#
# Indexes
#
#  IX_course_accrediting_provider_id          (accrediting_provider_id)
#  IX_course_provider_id_course_code          (provider_id,course_code) UNIQUE
#  index_course_on_accrediting_provider_code  (accrediting_provider_code)
#  index_course_on_changed_at                 (changed_at) UNIQUE
#  index_course_on_discarded_at               (discarded_at)
#

class Course < ApplicationRecord
  include Discard::Model
  include WithQualifications
  include ChangedAt
  include Courses::EditOptions
  include StudyModeVacancyMapper

  after_initialize :set_defaults

  before_discard do
    raise "You cannot delete the running course #{self}" unless ucas_status == :new
  end

  has_associated_audits
  audited
  validates :course_code,
            uniqueness: { scope: :provider_id },
            on: %i[create update]

  enum program_type: {
    higher_education_programme: "HE",
    school_direct_training_programme: "SD",
    school_direct_salaried_training_programme: "SS",
    scitt_programme: "SC",
    pg_teaching_apprenticeship: "TA",
  }

  enum study_mode: {
    full_time: "F",
    part_time: "P",
    full_time_or_part_time: "B",
  }

  enum level: {
    primary: "Primary",
    secondary: "Secondary",
    further_education: "Further education",
  }, _suffix: :course

  ENTRY_REQUIREMENT_OPTIONS = {
    must_have_qualification_at_application_time: 1,
    expect_to_achieve_before_training_begins: 2,
    equivalence_test: 3,
    not_required: 9,
    not_set: nil,
  }.freeze

  enum maths: ENTRY_REQUIREMENT_OPTIONS, _suffix: :for_maths
  enum english: ENTRY_REQUIREMENT_OPTIONS, _suffix: :for_english
  enum science: ENTRY_REQUIREMENT_OPTIONS, _suffix: :for_science

  before_save :set_applications_open_from

  belongs_to :provider

  belongs_to :accrediting_provider,
             ->(c) { where(recruitment_cycle: c.recruitment_cycle) },
             class_name: "Provider",
             foreign_key: :accrediting_provider_code,
             primary_key: :provider_code,
             inverse_of: :accredited_courses,
             optional: true

  has_many :course_subjects
  has_many :subjects, through: :course_subjects
  has_many :financial_incentives, through: :subjects
  has_many :site_statuses
  has_many :sites,
           -> { distinct.merge(SiteStatus.where(status: %i[new_status running])) },
           through: :site_statuses

  has_many :enrichments,
           class_name: "CourseEnrichment" do
    def find_or_initialize_draft
      # This is a ruby search as opposed to an AR search, because calling `draft`
      # will return a new instance of a CourseEnrichment object which is different
      # to the ones in the cached `enrichments` association. This makes checking
      # for validations later down non-trivial.
      latest_draft_enrichment = select(&:draft?).last

      latest_draft_enrichment || new(new_draft_attributes)
    end

    def new_draft_attributes
      latest_published_enrichment = latest_first.published.first

      if latest_published_enrichment.present?
        latest_published_enrichment_attributes = latest_published_enrichment
          .dup
          .attributes
          .with_indifferent_access
          .except(:json_data)

        latest_published_enrichment_attributes[:status] = :draft
        latest_published_enrichment_attributes
      else
        { status: :draft }.with_indifferent_access
      end
    end
  end

  scope :changed_since, ->(timestamp) do
    if timestamp.present?
      where("course.changed_at > ?", timestamp)
    else
      where.not(changed_at: nil)
    end.order(:changed_at, :id)
  end

  scope :not_new, -> do
    includes(site_statuses: %i[site course])
      .where
      .not(SiteStatus.table_name => { status: SiteStatus.statuses[:new_status] })
  end

  def self.entry_requirement_options_without_nil_choice
    ENTRY_REQUIREMENT_OPTIONS.reject { |option| option == :not_set }.keys.map(&:to_s)
  end

  validates :maths,   inclusion: { in: entry_requirement_options_without_nil_choice }, unless: :further_education_course?
  validates :english, inclusion: { in: entry_requirement_options_without_nil_choice }, unless: :further_education_course?
  validates :science, inclusion: { in: entry_requirement_options_without_nil_choice }, if: :gcse_science_required?
  validates :enrichments, presence: true, on: :publish
  validates :is_send, inclusion: { in: [true, false] }
  validates :sites, presence: true, on: %i[publish new]
  validates :subjects, presence: true, on: :publish
  validate :validate_enrichment_publishable, on: :publish
  validate :validate_site_statuses_publishable, on: :publish
  validate :validate_enrichment
  validate :validate_course_syncable, on: :sync
  validate :validate_qualification, on: %i[update new]
  validate :validate_start_date, on: :update, if: -> { provider.present? && start_date.present? }
  validate :validate_applications_open_from, on: %i[update new], if: -> { provider.present? }
  validate :validate_modern_languages
  validate :validate_has_languages, if: :has_the_modern_languages_secondary_subject_type?
  validate :validate_subject_count
  validate :validate_subject_consistency
  validate :validate_custom_age_range, on: %i[create new], if: -> { age_range_in_years.present? }

  validates :name, :profpost_flag, :program_type, :qualification, :start_date, :study_mode, presence: true
  validates :age_range_in_years, presence: true, on: %i[new create], unless: :further_education_course?
  validates :level, presence: true, on: %i[new create publish]

  after_validation :remove_unnecessary_enrichments_validation_message

  def self.get_by_codes(year, provider_code, course_code)
    RecruitmentCycle.find_by(year: year)
      .providers.find_by(provider_code: provider_code)
      .courses.find_by(course_code: course_code)
  end

  def recruitment_cycle
    provider.recruitment_cycle
  end

  def generate_name
    services[:generate_course_name].execute(course: self)
  end

  def accrediting_provider_description
    return nil if accrediting_provider.blank?

    return nil if provider.accrediting_provider_enrichments.blank?

    accrediting_provider_enrichment = provider.accrediting_provider_enrichments
      .find do |provider|
      provider.UcasProviderCode == accrediting_provider.provider_code
    end

    accrediting_provider_enrichment.Description if accrediting_provider_enrichment.present?
  end

  def publishable?
    valid? :publish
  end

  # Is course in syncable condition
  def syncable?
    valid? :sync
  end

  # Should we attempt to sync this course with Find
  def should_sync?
    recruitment_cycle.current? && is_published?
  end

  def update_valid?
    valid? :update
  end

  def findable?
    findable_site_statuses.any?
  end

  def findable_site_statuses
    if site_statuses.loaded?
      site_statuses.select(&:findable?)
    else
      site_statuses.findable
    end
  end

  def syncable_subjects
    if subjects.loaded?
      subjects
        .reject { |s| s.type == "DiscontinuedSubject" }
        .select { |s| s.subject_code.present? }
    else
      subjects
        .where.not(type: "DiscontinuedSubject")
        .where.not(subject_code: nil)
    end
  end

  def open_for_applications?
    applications_open_from.present? && applications_open_from <= Time.now.utc && findable?
  end

  def has_vacancies?
    if site_statuses.loaded?
      site_statuses.select(&:findable?).select(&:with_vacancies?).any?
    else
      site_statuses.findable.with_vacancies.any?
    end
  end

  def update_changed_at(timestamp: Time.now.utc)
    # Changed_at represents changes to related records as well as course
    # itself, so we don't want to alter the semantics of updated_at which
    # represents changes to just the course record.
    update_columns changed_at: timestamp
  end

  def study_mode_description
    study_mode.to_s.tr("_", " ")
  end

  def program_type_description
    if school_direct_salaried_training_programme? then " with salary"
    elsif pg_teaching_apprenticeship? then " teaching apprenticeship"
    else ""
    end
  end

  def description
    study_mode_string = (full_time_or_part_time? ? ", " : " ") +
      study_mode_description
    qualifications_description + study_mode_string + program_type_description
  end

  def content_status
    newest_enrichment = enrichments.latest_first.first
    services[:content_status].execute(enrichment: newest_enrichment, recruitment_cycle: recruitment_cycle)
  end

  def ucas_status
    return :running if findable?
    return :new if site_statuses.empty? || site_statuses.any?(&:status_new_status?)

    :not_running
  end

  def funding_type
    return nil if program_type.nil?

    if school_direct_salaried_training_programme?
      "salary"
    elsif pg_teaching_apprenticeship?
      "apprenticeship"
    else
      "fee"
    end
  end

  def is_fee_based?
    funding_type == "fee"
  end

  # https://www.gov.uk/government/publications/initial-teacher-training-criteria/initial-teacher-training-itt-criteria-and-supporting-advice#c11-gcse-standard-equivalent
  def gcse_subjects_required
    case level
    when "primary"
      %w[maths english science]
    when "secondary"
      %w[maths english]
    else
      []
    end
  end

  def gcse_science_required?
    gcse_subjects_required.include?("science")
  end

  def last_published_at
    newest_enrichment = enrichments.latest_first.first
    newest_enrichment&.last_published_timestamp_utc
  end

  def publish_sites
    site_statuses.status_new_status.each(&:start!)
    site_statuses.status_running.unpublished_on_ucas.each(&:published_on_ucas!)
  end

  def publish_enrichment(current_user)
    enrichments.draft.each do |enrichment|
      enrichment.publish(current_user)
    end
  end

  def add_site!(site:)
    is_course_new = ucas_status == :new # persist this before we change anything
    site_status = site_statuses.find_or_initialize_by(site: site)
    site_status.start! unless is_course_new
    site_status.save! if persisted?
  end

  def remove_site!(site:)
    site_status = site_statuses.find_by!(site: site)
    ucas_status == :new ? site_status.destroy! : site_status.suspend!
  end

  def sites=(desired_sites)
    existing_sites = sites

    to_add = desired_sites - existing_sites
    to_add.each { |site| add_site!(site: site) }

    to_remove = existing_sites - desired_sites
    to_remove.each { |site| remove_site!(site: site) }

    if persisted?
      sites.reload
    else
      super(desired_sites)
    end
  end

  def has_bursary?
    financial_incentives.any?(&:bursary_amount?)
  end

  def has_scholarship_and_bursary?
    financial_incentives.any?(&:scholarship?) && financial_incentives.any?(&:bursary_amount?)
  end

  def has_early_career_payments?
    financial_incentives.any?(&:early_career_payments?)
  end

  def bursary_amount
    financial_incentives&.first&.bursary_amount
  end

  def scholarship_amount
    financial_incentives&.first&.scholarship
  end

  def self_accredited?
    accrediting_provider.blank?
  end

  def to_s
    "#{name} (#{provider.provider_code}/#{course_code}) [#{recruitment_cycle}]"
  end

  def next_recruitment_cycle?
    recruitment_cycle.year > RecruitmentCycle.current_recruitment_cycle.year
  end

  # Ideally this would just use the validation, but:
  # https://github.com/rails/rails/issues/13971
  def course_params_assignable(course_params)
    assignable_after_publish(course_params) &&
      entry_requirements_assignable(course_params) &&
      qualification_assignable(course_params)
  end

  def is_published?
    %i{published published_with_unpublished_changes}.include? content_status
  end

  def funding_type=(funding_type)
    assign_program_type_service = Courses::AssignProgramTypeService.new
    assign_program_type_service.execute(funding_type, self)
  end

  def ensure_modern_languages
    if has_any_modern_language_subject_type? && !has_the_modern_languages_secondary_subject_type?
      subjects << SecondarySubject.modern_languages
    end
  end

  def ensure_site_statuses_match_study_mode
    site_statuses.select(&:with_vacancies?).each do |site_status|
      update_vac_status(study_mode, site_status)
    end
  end

  def withdraw
    if is_published?
      site_statuses.each do |site_status|
        site_status.update(vac_status: :no_vacancies, status: :suspended)
      end

      withdraw_latest_enrichment
    else
      errors.add(:withdraw, "Courses that have not been published should be deleted not withdrawn")
    end
  end

  def assignable_master_subjects
    services[:assignable_master_subjects].execute(course: self)
  end

  def assignable_subjects
    services[:assignable_subjects].execute(course: self)
  end

private

  def withdraw_latest_enrichment
    newest_enrichment = enrichments.latest_first.first
    newest_enrichment.withdraw
  end

  def assignable_after_publish(course_params)
    relevant_params = course_params.slice(:is_send, :applications_open_from, :application_start_date)

    return true if relevant_params.empty? || !is_published?

    relevant_params.each do |field, _value|
      errors.add(field.to_sym, "cannot be changed after publish")
    end
    false
  end

  def entry_requirements_assignable(course_params)
    relevant_params = course_params.slice(:maths, :english, :science)

    invalid_params = relevant_params.select do |_subject, value|
      value && !ENTRY_REQUIREMENT_OPTIONS.key?(value.to_sym)
    end
    invalid_params.each do |subject, _value|
      errors.add(subject.to_sym, "is invalid")
    end

    invalid_params.empty?
  end

  def qualification_assignable(course_params)
    assignable = course_params[:qualification].nil? || Course::qualifications.include?(course_params[:qualification].to_sym)
    errors.add(:qualification, "is invalid") unless assignable

    assignable
  end

  def add_enrichment_errors(enrichment)
    enrichment.errors.messages.map do |field, _error|
      # `full_messages_for` here will remove any `^`s defined in the validator or en.yml.
      # We still need it for later, so re-add it.
      # jsonapi_errors will throw if it's given an array, so we call `.first`.
      message = "^" + enrichment.errors.full_messages_for(field).first.to_s
      errors.add field.to_sym, message
    end
  end

  def validate_enrichment(validation_scope = nil)
    latest_enrichment = enrichments.select(&:draft?).last
    return if latest_enrichment.blank?

    latest_enrichment.valid? validation_scope
    add_enrichment_errors(latest_enrichment)
  end

  def validate_enrichment_publishable
    validate_enrichment :publish
  end

  def validate_site_statuses_publishable
    site_statuses.each do |site_status|
      unless site_status.valid?
        raise RuntimeError.new("Site status invalid on course #{provider.provider_code}/#{course_code}: #{site_status.errors.full_messages.first}")
      end
    end
  end

  def set_defaults
    self.modular ||= ""
  end

  def remove_unnecessary_enrichments_validation_message
    self.errors.delete :enrichments if self.errors[:enrichments] == ["is invalid"]
  end

  def validate_course_syncable
    if findable?.blank?
      errors.add :site_statuses, "No findable sites."
    end

    if syncable_subjects.none?
      errors.add :subjects, "No subjects."
    end
  end

  def validate_qualification
    if qualification.blank?
      errors.add(:qualification, :blank)
    else
      errors.add(:qualification, "^#{qualifications_description} is not valid for a #{level.to_s.humanize.downcase} course") unless qualification.in?(qualification_options)
    end
  end

  def set_applications_open_from
    self.applications_open_from ||= recruitment_cycle.application_start_date
  end

  def validate_start_date
    errors.add :start_date, "#{start_date.strftime('%B %Y')} is not in the #{recruitment_cycle.year} cycle" unless start_date_options.include?(start_date.strftime("%B %Y"))
  end

  def validate_applications_open_from
    if applications_open_from.blank?
      errors.add(:applications_open_from, :blank)
    elsif !valid_date_range.include?(applications_open_from)
      chosen_date = applications_open_from.strftime("%d/%m/%Y")
      start_date = recruitment_cycle.application_start_date.strftime("%d/%m/%Y")
      end_date = recruitment_cycle.application_end_date.strftime("%d/%m/%Y")
      errors.add(
        :applications_open_from,
        "#{chosen_date} is not valid for the #{provider.recruitment_cycle.year} cycle. " +
        "A valid date must be between #{start_date} and #{end_date}",
      )
    end
  end

  def validate_modern_languages
    if has_any_modern_language_subject_type? && !has_the_modern_languages_secondary_subject_type?
      errors.add(:subjects, "Modern languages subjects must also have the modern_languages subject")
    end
  end

  def validate_site_status_findable
    unless findable?
      errors.add(:site_statuses, "must be findable")
    end
  end

  def has_any_modern_language_subject_type?
    subjects.any? { |subject| subject.type == "ModernLanguagesSubject" }
  end

  def has_the_modern_languages_secondary_subject_type?
    raise "SecondarySubject not found" if SecondarySubject == nil
    raise "SecondarySubject.modern_languages not found" if SecondarySubject.modern_languages == nil

    subjects.any? { |subject| subject&.id == SecondarySubject.modern_languages.id }
  end

  def validate_has_languages
    unless has_any_modern_language_subject_type?
      errors.add(:subjects, :select_a_language)
    end
  end

  def validate_subject_count
    if subjects.empty?
      errors.add(:subjects, :course_creation)
      return
    end

    case level
    when "primary", "further_education"
      if subjects.count > 1
        errors.add(:subjects, "has too many subjects")
      end
    when "secondary"
      if subjects.count > 2 && !has_any_modern_language_subject_type?
        errors.add(:subjects, "has too many subjects")
      end
    end
  end

  def validate_subject_consistency
    subjects_excluding_discontinued = subjects.reject do |subject|
      DiscontinuedSubject.exists?(id: subject.id)
    end

    return if subjects_excluding_discontinued.empty?

    case level
    when "primary"
      unless PrimarySubject.exists?(id: subjects_excluding_discontinued.map(&:id))
        errors.add(:subjects, "must be primary")
      end
    when "secondary"
      unless SecondarySubject.exists?(id: subjects_excluding_discontinued.map(&:id))
        errors.add(:subjects, "must be secondary")
      end
    when "further_education"
      unless FurtherEducationSubject.exists?(id: subjects_excluding_discontinued.map(&:id))
        errors.add(:subjects, "must be further education")
      end
    end
  end

  def validate_custom_age_range
    # This regex checks that a 1 or 2 digit number is selected for the 'to' and 'from' values.
    # It also checks that the age range is correctly formatted with _to_ in between these values
    valid_regex_pattern = /^(\d{1,2})_to_(\d{1,2})$/
    #The below grabs the 'from' and 'to' ages and puts them into variables if the regex is valid
    from_age, to_age = valid_regex_pattern.match(age_range_in_years).captures if valid_regex_pattern.match(age_range_in_years)

    error_message = "#{age_range_in_years} is invalid. You must enter a valid age range."

    if !valid_regex_pattern.match(age_range_in_years)
      errors.add(:age_range_in_years, error_message)
    elsif from_age.to_i < 3 || from_age.to_i > 14
      errors.add(:age_range_in_years_from, error_message)
    elsif to_age.to_i < 7 || to_age.to_i > 18
      errors.add(:age_range_in_years_to, error_message)
    elsif to_age.to_i - from_age.to_i < 4
      errors.add(:age_range_in_years, "#{age_range_in_years} is invalid. Your age range must cover at least 4 years.")
    end
  end

  def valid_date_range
    recruitment_cycle.application_start_date..recruitment_cycle.application_end_date
  end

  def services
    return @services if @services.present?

    @services = Dry::Container.new
    @services.register(:generate_course_name) do
      Courses::GenerateCourseNameService.new
    end
    @services.register(:assignable_master_subjects) do
      Courses::AssignableMasterSubjectService.new
    end
    @services.register(:assignable_subjects) do
      Courses::AssignableSubjectService.new
    end
    @services.register(:content_status) do
      Courses::ContentStatusService.new
    end
  end
end
