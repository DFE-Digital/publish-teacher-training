# frozen_string_literal: true

class CourseSubject < ApplicationRecord
  self.table_name = "course_subject"

  belongs_to :course
  belongs_to :subject
  validates :subject_id, uniqueness: { scope: :course_id }
  validates :position, presence: true, inclusion: { in: 0.. }, uniqueness: { scope: :course_id }, on: :create # rubocop:disable Rails/UniqueValidationWithoutIndex

  audited associated_with: :course
end
