# frozen_string_literal: true

class CourseEnrichment < ApplicationRecord
  include TouchCourse
  include RecruitmentCycleHelper
  enum :status, { draft: 0, published: 1, rolled_over: 2, withdrawn: 3 }

  jsonb_accessor :json_data,
                 about_course: [:string, { store_key: "AboutCourse" }],
                 course_length: [:string, { store_key: "CourseLength" }],
                 fee_details: [:string, { store_key: "FeeDetails" }],
                 fee_international: [:integer, { store_key: "FeeInternational" }],
                 fee_uk_eu: [:integer, { store_key: "FeeUkEu" }],
                 financial_support: [:string, { store_key: "FinancialSupport" }],
                 how_school_placements_work: [:string,
                                              { store_key: "HowSchoolPlacementsWork" }],
                 interview_process: [:string, { store_key: "InterviewProcess" }],
                 other_requirements: [:string, { store_key: "OtherRequirements" }],
                 personal_qualities: [:string, { store_key: "PersonalQualities" }],
                 required_qualifications: [:string, { store_key: "Qualifications" }],
                 salary_details: [:string, { store_key: "SalaryDetails" }],
                 describe_school: [:string, { store_key: "DescribeSchool" }],
                 candidate_training_rationale: [:string, { store_key: "CandidateTrainingRationale" }],
                 placement_selection_criteria: [:string, { store_key: "PlacementSelectionCriteria" }],
                 duration_per_school: [:string, { store_key: "DurationPerSchool" }],
                 theoretical_training_location: [:string, { store_key: "TheoreticalTrainingLocation" }],
                 theoretical_training_duration: [:string, { store_key: "TheoreticalTrainingDuration" }],
                 placement_school_activities: [:string, { store_key: "PlacementSchoolActivities" }],
                 support_and_mentorship: [:string, { store_key: "SupportAndMentorship" }],
                 theoretical_training_activities: [:string, { store_key: "TheoreticalTrainingActivities" }],
                 assessment_methods: [:string, { store_key: "AssessmentMethods" }],
                 interview_location: [:string, { store_key: "InterviewLocation" }],
                 fee_schedule: [:string, { store_key: "FeeSchedule" }],
                 additional_fees: [:string, { store_key: "AdditionalFees" }]

  belongs_to :course

  scope :most_recent, -> { order(created_at: :desc, id: :desc) }
  scope :draft, -> { where(status: "draft").or(rolled_over) }

  def draft?
    status.in? %w[draft rolled_over]
  end

  # About this course
  validates :about_course, presence: true, on: :publish, if: -> { version == 1 }
  validates :about_course, words_count: { maximum: 400 }

  validates :interview_process, words_count: { maximum: 250 }, if: -> { version == 1 }

  validates :how_school_placements_work, presence: true, on: :publish, if: -> { version == 1 }
  validates :how_school_placements_work, words_count: { maximum: 350 }

  # Course length and fees
  validates :course_length, presence: true, on: :publish

  validates :fee_uk_eu, presence: true, on: :publish, if: :is_fee_based?

  validates :fee_international, presence: true, on: :publish, if: -> { is_fee_based? && course.can_sponsor_student_visa? }

  validates :fee_uk_eu,
            numericality: { allow_blank: true,
                            only_integer: true,
                            greater_than_or_equal_to: 0,
                            less_than_or_equal_to: 100_000 },
            if: :is_fee_based?

  validates :fee_international,
            numericality: { allow_blank: true,
                            only_integer: true,
                            greater_than_or_equal_to: 0,
                            less_than_or_equal_to: 100_000 },
            if: :is_fee_based?

  validates :fee_details, words_count: { maximum: 250 }, if: :is_fee_based?

  validates :financial_support,
            words_count: { maximum: 250 },
            if: -> { is_fee_based? && version == 1 }

  validates :financial_support,
            words_count: { maximum: 50 },
            if: -> { is_fee_based? && version == 2 }

  # Course length and salary
  validates :salary_details, presence: true, on: :publish, unless: :is_fee_based?
  validates :salary_details, words_count: { maximum: 250 }, unless: :is_fee_based?

  # Requirements and qualifications

  validates :required_qualifications, presence: true, on: :publish, if: :required_qualifications_needed?
  validates :required_qualifications, words_count: { maximum: 100 }

  validates :personal_qualities, words_count: { maximum: 100 }
  validates :other_requirements, words_count: { maximum: 100 }

  # v2 validations
  validates :describe_school, presence: true, on: :publish, if: -> { version == 2 }
  validates :describe_school, words_count: { maximum: 100 }
  validates :candidate_training_rationale, presence: true, on: :publish, if: -> { version == 2 }
  validates :candidate_training_rationale, words_count: { maximum: 100 }

  validates :placement_selection_criteria, presence: true, on: :publish, if: -> { version == 2 }
  validates :placement_selection_criteria, words_count: { maximum: 50 }
  validates :duration_per_school, presence: true, on: :publish, if: -> { version == 2 }
  validates :duration_per_school, words_count: { maximum: 50 }
  validates :theoretical_training_location, presence: true, on: :publish, if: -> { version == 2 }
  validates :theoretical_training_location, words_count: { maximum: 50 }

  validates :placement_school_activities, presence: true, on: :publish, if: -> { version == 2 }
  validates :placement_school_activities, words_count: { maximum: 150 }
  validates :support_and_mentorship, presence: true, on: :publish, if: -> { version == 2 }
  validates :support_and_mentorship, words_count: { maximum: 50 }

  validates :theoretical_training_activities, presence: true, on: :publish, if: -> { version == 2 }
  validates :theoretical_training_activities, words_count: { maximum: 150 }

  validates :interview_process, presence: true, on: :publish, if: -> { version == 2 }
  validates :interview_process, words_count: { maximum: 200 }, if: -> { version == 2 }

  # v2 optional fields
  validates :theoretical_training_duration, words_count: { maximum: 50 }
  validates :interview_location, inclusion: { in: ["onsite", "in person", "both", nil] }
  validates :fee_schedule, words_count: { maximum: 50 }, if: :is_fee_based?
  validates :additional_fees, words_count: { maximum: 50 }, if: :is_fee_based?
  validates :assessment_methods, words_count: { maximum: 50 }

  def version
    self[:version] || 1
  end

  def is_fee_based?
    course&.fee_based?
  end

  def has_been_published_before?
    last_published_timestamp_utc.present?
  end

  def publish(current_user)
    update(status: "published",
           last_published_timestamp_utc: Time.now.utc,
           updated_by_user_id: current_user.id)
  end

  def unpublish(initial_draft: true)
    data = { status: :draft }
    data[:last_published_timestamp_utc] = nil if initial_draft
    update(data)
  end

  def withdraw
    update(status: "withdrawn")
  end

  def required_qualifications_needed?
    course&.provider&.recruitment_cycle&.year.to_i < Course::STRUCTURED_REQUIREMENTS_REQUIRED_FROM
  end
end
