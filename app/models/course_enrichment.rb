# == Schema Information
#
# Table name: course_enrichment
#
#  id                           :integer          not null, primary key
#  created_by_user_id           :integer
#  created_at                   :datetime         not null
#  provider_code                :text             not null
#  json_data                    :jsonb
#  last_published_timestamp_utc :datetime
#  status                       :integer          not null
#  ucas_course_code             :text             not null
#  updated_by_user_id           :integer
#  updated_at                   :datetime         not null
#

class CourseEnrichment < ApplicationRecord
  include TouchCourse

  enum status: %i[draft published]

  jsonb_accessor :json_data,
                 about_course: [:string, store_key: 'AboutCourse'],
                 course_length: [:string, store_key: 'CourseLength'],
                 fee_details: [:string, store_key: 'FeeDetails'],
                 fee_international: [:integer, store_key: 'FeeInternational'],
                 fee_uk_eu: [:integer, store_key: 'FeeUkEu'],
                 financial_support: [:string, store_key: 'FinancialSupport'],
                 how_school_placements_work: [:string,
                                              store_key: 'HowSchoolPlacementsWork'],
                 interview_process: [:string, store_key: 'InterviewProcess'],
                 other_requirements: [:string, store_key: 'OtherRequirements'],
                 personal_qualities: [:string, store_key: 'PersonalQualities'],
                 qualifications: [:string, store_key: 'Qualifications'],
                 salary_details: [:string, store_key: 'SalaryDetails']

  belongs_to :provider, foreign_key: :provider_code, primary_key: :provider_code
  belongs_to :course,
             ->(enrichment) { where(provider_id: enrichment.provider.id) },
             foreign_key: :ucas_course_code,
             primary_key: :course_code

  scope :latest_first, -> { order(created_at: :desc, id: :desc) }

  validates :ucas_course_code, presence: true
  validates :course, presence: true
  validates :provider_code, presence: true
  validates :provider, presence: true

  validates :about_course, presence: true, on: :publish
  validates :about_course, words_count: { maximum: 400 }

  validates :course_length, presence: true, on: :publish

  validates :fee_international,
            numericality: { only_integer: true,
                            greater_than_or_equal_to: 0,
                            less_than_or_equal_to: 100000 },
            if: :is_fee_based?

  validates :fee_details, words_count: { maximum: 250 }, if: :is_fee_based?

  validates :fee_uk_eu, presence: true, on: :publish, if: :is_fee_based?
  validates :fee_uk_eu,
            numericality: { only_integer: true,
                            greater_than_or_equal_to: 0,
                            less_than_or_equal_to: 100000 },
            if: :is_fee_based?

  validates :financial_support,
            words_count: { maximum: 250 },
            if: :is_fee_based?

  validates :how_school_placements_work, presence: true, on: :publish
  validates :how_school_placements_work, words_count: { maximum: 350 }

  validates :interview_process, words_count: { maximum: 250 }

  validates :qualifications, presence: true, on: :publish
  validates :qualifications, words_count: { maximum: 100 }

  validates :salary_details, presence: true, on: :publish, unless: :is_fee_based?
  validates :salary_details, words_count: { maximum: 250 }, unless: :is_fee_based?

  def is_fee_based?
    course&.is_fee_based?
  end

  def has_been_published_before?
    last_published_timestamp_utc.present?
  end

  def publish(current_user)
    update(status: 'published',
          last_published_timestamp_utc: Time.now.utc,
          updated_by_user_id: current_user.id)
  end

  def unpublish(initial_draft: true)
    data = { status: :draft }
    data[:last_published_timestamp_utc] = nil if initial_draft
    update(data)
  end
end
