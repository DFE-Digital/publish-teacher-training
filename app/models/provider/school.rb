# frozen_string_literal: true

class Provider::School < ApplicationRecord
  include TouchProvider

  self.table_name = "provider_school"

  MAIN_SITE_CODE = "-"

  after_destroy :touch_provider

  belongs_to :provider, class_name: "::Provider", inverse_of: :schools
  belongs_to :gias_school

  has_many :course_schools, class_name: "Course::School", inverse_of: :provider_school, dependent: :destroy

  validates :site_code, presence: true
  validates :gias_school_id, uniqueness: { scope: %i[provider_id site_code] }
  validates :site_code,
            uniqueness: {
              scope: :provider_id,
              conditions: -> { where(site_code: MAIN_SITE_CODE) },
              message: :only_one_main_site_per_provider,
            },
            if: -> { site_code == MAIN_SITE_CODE }
end
