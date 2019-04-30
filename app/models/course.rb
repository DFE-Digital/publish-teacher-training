# == Schema Information
#
# Table name: course
#
#  id                      :integer          not null, primary key
#  age_range               :text
#  course_code             :text
#  name                    :text
#  profpost_flag           :text
#  program_type            :text
#  qualification           :integer          not null
#  start_date              :datetime
#  study_mode              :text
#  accrediting_provider_id :integer
#  provider_id             :integer          default(0), not null
#  modular                 :text
#  english                 :integer
#  maths                   :integer
#  science                 :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  changed_at              :datetime         not null
#

class Course < ApplicationRecord
  include WithQualifications
  include ChangedAt

  has_associated_audits
  audited except: :changed_at
  validates :course_code, uniqueness: { scope: :provider_id }

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

  enum age_range: {
    primary: "P",
    secondary: "S",
    middle_years: "M",
    # 'other' doesn't exist in the data yet but is reserved for courses that don't fit
    # the above categories
    other: "O",
  }

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

  belongs_to :provider
  belongs_to :accrediting_provider, class_name: 'Provider', optional: true
  has_many :course_subjects
  has_many :subjects, through: :course_subjects
  has_many :site_statuses
  has_many :sites, through: :site_statuses

  has_many :enrichments,
           ->(course) { where(provider_code: course.provider.provider_code) },
           foreign_key: :ucas_course_code,
           primary_key: :course_code,
           class_name: 'CourseEnrichment'

  scope :changed_since, ->(timestamp) do
    if timestamp.present?
      where("course.changed_at > ?", timestamp)
    else
      where.not(changed_at: nil)
    end.order(:changed_at, :id)
  end

  validates :enrichments, presence: true, on: :publish
  validate :validate_enrichment, on: :publish

  def publishable?
    valid? :publish
  end

  def validate_enrichment
    latest_enrichment = enrichments.latest_first.first
    if latest_enrichment.present?
      latest_enrichment.valid? :publish
      latest_enrichment.errors.messages.each do |field, _error|
        # Compute a key of `latest_enrichment__FIELD` to allow the frontend to determine
        # which field should be linked to from the error title.
        key = "latest_enrichment__#{field}".to_sym
        # `full_messages_for` here will remove any `^`s defined in the validator or en.yml.
        # We still need it for later, so re-add it.
        # jsonapi_errors will throw if it's given an array, so we call `.first`.
        message = "^" + latest_enrichment.errors.full_messages_for(field).first.to_s
        errors.add key, message
      end
    end
  end

  def recruitment_cycle
    "2019"
  end

  def findable?
    site_statuses.findable.any?
  end

  def new?
    site_statuses.empty? || site_statuses.status_new_status.any?
  end

  def open_for_applications?
    site_statuses.open_for_applications.any?
  end

  def applications_open_from
    site_statuses
      .open_for_applications
      .order("applications_accepted_from ASC")
      .first
      &.applications_accepted_from
      &.to_datetime
      &.utc
      &.iso8601
  end

  def has_vacancies?
    site_statuses.findable.with_vacancies.any?
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
    newest_enrichment = enrichments.order('created_at desc').first

    if newest_enrichment.nil?
      :empty
    elsif newest_enrichment.published?
      :published
    elsif newest_enrichment.has_been_published_before?
      :published_with_unpublished_changes
    else
      :draft
    end
  end

  def ucas_status
    return :running if findable?
    return :new if new?

    :not_running
  end

  def funding
    if school_direct_salaried_training_programme?
      'salary'
    elsif pg_teaching_apprenticeship?
      'apprenticeship'
    else
      'fee'
    end
  end

  def dfe_subjects
    SubjectMapperService.get_subject_list(name, subjects.map(&:subject_name))
  end

  def level
    Subjects::CourseLevel.new(subjects.map(&:subject_name)).level
  end

  def is_send?
    subjects.any?(&:is_send?)
  end

  def is_fee_based?
    funding == 'fee'
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
    is_course_new = new? # persist this before we change anything
    site_status = site_statuses.find_or_create_by!(site: site)
    site_status.start! unless is_course_new
  end

  def remove_site!(site:)
    site_status = site_statuses.find_by!(site: site)
    new? ? site_status.destroy! : site_status.suspend!
  end

  def applications_accepted_from=(new_date)
    site_statuses.each { |ss| ss.update(applications_accepted_from: new_date) }
  end

  def sites_not_associated_with_course
    provider.sites - sites
  end

  def has_bursary?
    dfe_subjects.any?(&:has_bursary?)
  end

  def has_scholarship_and_bursary?
    dfe_subjects.any?(&:has_scholarship_and_bursary?)
  end
end
