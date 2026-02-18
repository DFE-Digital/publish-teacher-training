class SavedCourse < ApplicationRecord
  belongs_to :candidate
  belongs_to :course

  scope :not_withdrawn, lambda {
    where.not(
      course_id: Course
        .joins(:latest_enrichment)
        .where(course_enrichment: { status: CourseEnrichment.statuses[:withdrawn] })
        .select(:id),
    )
  }

  validates :candidate_id, uniqueness: { scope: :course_id }
  validates :note, words_count: { maximum: 100, message: :too_long }
end
