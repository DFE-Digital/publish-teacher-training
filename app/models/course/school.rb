# frozen_string_literal: true

class Course::School < ApplicationRecord
  include TouchCourse

  self.table_name = "course_school"

  belongs_to :course, class_name: "::Course", inverse_of: :schools
  belongs_to :gias_school
  belongs_to :provider_school, class_name: "Provider::School", inverse_of: :course_schools

  validates :site_code, presence: true
  validates :provider_school_id, uniqueness: { scope: :course_id }
  validate :consistent_with_provider_school

private

  # gias_school_id and site_code are denormalised copies of the linked
  # Provider::School (gias_school_id is kept so courses can be filtered by the
  # GIAS school's lat/long without joining provider_school). Guard against the
  # two sources of truth drifting apart.
  def consistent_with_provider_school
    return if provider_school.blank?

    # Compare the records, not the *_id columns: a not-yet-saved gias_school has
    # a nil foreign key until belongs_to autosave runs (after validation), so a
    # column comparison would spuriously fail on create.
    if gias_school != provider_school.gias_school
      errors.add(:gias_school_id, "must match the provider school's GIAS school")
    end

    if site_code != provider_school.site_code
      errors.add(:site_code, "must match the provider school's site code")
    end
  end
end
