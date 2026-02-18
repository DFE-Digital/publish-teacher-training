class SavedCourse < ApplicationRecord
  belongs_to :candidate
  belongs_to :course

  scope :not_withdrawn, lambda {
    joins(course: :latest_enrichment)
      .merge(Course.findable)
      .where.not(course_enrichment: { status: CourseEnrichment.statuses[:withdrawn] })
      .distinct
  }

  validates :candidate_id, uniqueness: { scope: :course_id }
  validates :note, words_count: { maximum: 100, message: :too_long }
end
