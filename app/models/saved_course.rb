class SavedCourse < ApplicationRecord
  belongs_to :candidate
  belongs_to :course

  validates :candidate_id, uniqueness: { scope: :course_id }
end
