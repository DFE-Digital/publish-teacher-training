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

  belongs_to :provider
  belongs_to :accrediting_provider, class_name: 'Provider', optional: true
  has_and_belongs_to_many :subjects
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

  scope :providers_have_opted_in, -> { joins(:provider).merge(Provider.opted_in) }

  validates :enrichments, presence: true, on: :publish
  validate :validate_enrichment, on: :publish

  def publishable?
    valid? :publish
  end

  def validate_enrichment
    latest = enrichments.latest_first.first
    if latest != nil
      latest.valid? :publish
      latest.errors.full_messages.each do |msg|
        errors.add :latest_enrichment, msg.to_s
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
    site_statuses.status_new_status.any?
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
    SubjectMapperService.get_subject_level(subjects.map(&:subject_name))
  end

  def is_send?
    subjects.any?(&:is_send?)
  end

  def last_published_at
    newest_enrichment = enrichments.latest_first.first
    newest_enrichment&.last_published_timestamp_utc
  end

  def publish_sites
    site_statuses.status_new_status.each(&:status_running!)
    site_statuses.status_running.unpublished_on_ucas.each(&:published_on_ucas!)
  end

  def publish_enrichment(current_user)
    enrichments.draft.each do |enrichment|
      enrichment.publish(current_user)
    end
  end
end
