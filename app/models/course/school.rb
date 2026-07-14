# frozen_string_literal: true

class Course::School < ApplicationRecord
  include TouchCourse

  self.table_name = "course_school"

  belongs_to :course, class_name: "::Course", inverse_of: :schools
  belongs_to :gias_school
  belongs_to :provider_school, class_name: "Provider::School", inverse_of: :course_schools

  validates :provider_school_id, uniqueness: { scope: :course_id }
  validate :consistent_with_provider_school

  delegate :site_code, to: :provider_school

private

  # gias_school_id is a denormalised copy of the linked Provider::School so
  # courses can be filtered by the GIAS school's lat/long without joining
  # provider_school. Guard against the two sources of truth drifting apart.
  def consistent_with_provider_school
    return if provider_school.blank?

    # Compare the records, not the *_id columns: a not-yet-saved gias_school has
    # a nil foreign key until belongs_to autosave runs (after validation), so a
    # column comparison would spuriously fail on create.
    if course.present? && course.provider != provider_school.provider
      errors.add(:provider_school_id, "must belong to the course's provider")
    end

    if gias_school != provider_school.gias_school
      errors.add(:gias_school_id, "must match the provider school's GIAS school")
    end
  end
end
