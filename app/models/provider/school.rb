# frozen_string_literal: true

class Provider::School < ApplicationRecord
  include TouchProvider

  self.table_name = "provider_school"

  MAIN_SITE_CODE = "-"

  after_destroy :touch_provider

  belongs_to :provider, class_name: "::Provider", inverse_of: :schools
  belongs_to :gias_school

  has_many :course_schools, class_name: "Course::School", inverse_of: :provider_school, dependent: :destroy

  delegate :recruitment_cycle, :provider_code, to: :provider, allow_nil: true
  delegate :urn, :address1, :address2, :address3, :town, :postcode, to: :gias_school

  validates :site_code, presence: true
  validates :gias_school_id, uniqueness: { scope: %i[provider_id site_code] }
  validates :site_code,
            uniqueness: {
              scope: :provider_id,
              conditions: -> { where(site_code: MAIN_SITE_CODE) },
              message: :only_one_main_site_per_provider,
            },
            if: -> { site_code == MAIN_SITE_CODE }

  def location_name
    return "#{gias_school.name} (Main site)" if site_code == MAIN_SITE_CODE

    gias_school.name
  end

  def code
    site_code
  end

  def full_address(join_on_separator = ", ")
    [
      gias_school.address1,
      gias_school.address2,
      gias_school.address3,
      gias_school.town,
      gias_school.county,
      gias_school.postcode,
    ].compact_blank.join(join_on_separator)
  end
end
