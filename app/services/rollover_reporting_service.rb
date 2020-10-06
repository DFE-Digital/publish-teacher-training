class RolloverReportingService
  def initialize
    @rollover_scope = RecruitmentCycle.current_recruitment_cycle
  end

  class << self
    def call
      new.call
    end
  end

  def call
    if @rollover_scope.next.blank?
      { total: {
          published_courses: 0,
          new_courses_published: 0,
          deleted_courses: 0,
          existing_courses_in_draft: 0,
          existing_courses_in_review: 0,
        } }
    else
      {
        total: {
          published_courses: published_courses_count,
          new_courses_published: new_courses_published_count,
          deleted_courses: deleted_courses_count,
          existing_courses_in_draft: existing_courses_in_draft_count,
          existing_courses_in_review: existing_courses_in_review,
        },
      }
    end
  end

  private_class_method :new

private

  def next_findable
    @rollover_scope.next.courses.findable
  end

  def published_courses
    next_findable
  end

  def published_courses_count
    published_courses.distinct.count
  end

  def new_courses_published
    next_findable.distinct.created_at_since(RecruitmentCycle.next.created_at + 1.day)
  end

  def new_courses_published_count
    new_courses_published.count
  end

  def deleted_courses
    Course.discarded.where(provider: Provider.where(recruitment_cycle: RecruitmentCycle.next))
  end

  def deleted_courses_count
    deleted_courses.count
  end

  def existing_courses_in_draft
    @rollover_scope.next.courses.changed_since(RecruitmentCycle.next.created_at + 1.day).where.not(id: published_courses)
  end

  def existing_courses_in_draft_count
    existing_courses_in_draft.distinct.count
  end

  def existing_courses_in_review
    @rollover_scope.next.courses.where.not(id: published_courses).where.not(id: deleted_courses).where.not(id: existing_courses_in_draft).count
  end
end
