class ReportingController < ActionController::API
  before_action :build_recruitment_cycle
  before_action :build_courses

  def reporting
    status = :ok

    render status: status, json: course_stats
  end

private

  def course_stats
    {
      total: {
        all: @courses.count,
        non_findable: @courses.count - @findable_courses.count,
        all_findable: @findable_courses.count,
      },
      findable_total: {
        open: @open_courses.count,
        closed: @closed_courses.count,
      },
      provider_type: { **group_by_count(:provider_type) },
      program_type: { **group_by_count(:program_type) },

      study_mode: { **group_by_count(:study_mode) },
      qualification: { **group_by_count(:qualification) },
      is_send: { **group_by_count(:is_send) },
    }
  end

  def group_by_count(column)
    open = @open_courses.group(column).count

    closed = @closed_courses.group(column).count

    {
      open: column == :provider_type ? open.transform_keys { |key| Provider.provider_types.key(key || "") } : open,
      closed: column == :provider_type ? closed.transform_keys { |key| Provider.provider_types.key(key || "") } : closed,
    }
  end

  def build_courses
    @courses = @recruitment_cycle.courses
    @findable_courses = @courses.findable.distinct
    @open_courses = @findable_courses.with_vacancies
    @closed_courses = @findable_courses.where.not id: @open_courses
  end

  def build_recruitment_cycle
    @recruitment_cycle = RecruitmentCycle.find_by(
      year: params[:recruitment_cycle_year],
    ) || RecruitmentCycle.current_recruitment_cycle
  end
end
