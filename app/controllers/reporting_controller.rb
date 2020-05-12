class ReportingController < ActionController::API
  before_action :build_recruitment_cycle

  def reporting
    course_stats = CourseReportingService.call(courses_scope: @recruitment_cycle.courses)

    render status: :ok, json: course_stats
  end

private

  def build_recruitment_cycle
    @recruitment_cycle = RecruitmentCycle.find_by(
      year: params[:recruitment_cycle_year],
    ) || RecruitmentCycle.current_recruitment_cycle
  end
end
