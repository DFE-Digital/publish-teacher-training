class CourseEnrichment < ApplicationRecord
  include TouchCourse
  enum status: { draft: 0, published: 1, rolled_over: 2, withdrawn: 3 }

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
                 salary_details: [:string, { store_key: "SalaryDetails" }]

  belongs_to :course

  scope :most_recent, -> { order(created_at: :desc, id: :desc) }
  scope :draft, -> { where(status: "draft").or(rolled_over) }

  def draft?
    status.in? %w[draft rolled_over]
  end

  # About this course
  # TODO POST MIGRATION: Move out of this as it's handled in the form object
  validates :about_course, presence: true, on: :publish
  validates :about_course, words_count: { maximum: 400 }

  validates :interview_process, words_count: { maximum: 250 }

  validates :how_school_placements_work, presence: true, on: :publish
  validates :how_school_placements_work, words_count: { maximum: 350 }

  # Course length and fees

  # TODO: POST MIGRATION: Move out of this as it's handled in the form object
  validates :course_length, presence: true, on: :publish

  validates :fee_uk_eu, presence: true, on: :publish, if: :is_fee_based?
  validates :fee_uk_eu,
            numericality: { allow_blank: true,
                            only_integer: true,
                            greater_than_or_equal_to: 0,
                            less_than_or_equal_to: 100000 },
            if: :is_fee_based?

  validates :fee_international,
            numericality: { allow_blank: true,
                            only_integer: true,
                            greater_than_or_equal_to: 0,
                            less_than_or_equal_to: 100000 },
            if: :is_fee_based?

  validates :fee_details, words_count: { maximum: 250 }, if: :is_fee_based?

  validates :financial_support,
            words_count: { maximum: 250 },
            if: :is_fee_based?

  # Course length and salary

  validates :salary_details, presence: true, on: :publish, unless: :is_fee_based?
  validates :salary_details, words_count: { maximum: 250 }, unless: :is_fee_based?

  # Requirements and qualifications

  validates :required_qualifications, presence: true, on: :publish, if: :required_qualifications_needed?
  validates :required_qualifications, words_count: { maximum: 100 }

  validates :personal_qualities, words_count: { maximum: 100 }

  validates :other_requirements, words_count: { maximum: 100 }

  def is_fee_based?
    course&.is_fee_based?
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
    (course&.provider&.recruitment_cycle&.year.to_i) < Course::STRUCTURED_REQUIREMENTS_REQUIRED_FROM
  end
end
