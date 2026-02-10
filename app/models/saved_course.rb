class SavedCourse < ApplicationRecord
  belongs_to :candidate
  belongs_to :course

  validates :candidate_id, uniqueness: { scope: :course_id }
  validates :note, words_count: { maximum: 100, message: :too_long }
end
