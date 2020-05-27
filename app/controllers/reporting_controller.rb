class ReportingController < ActionController::API
  before_action :build_recruitment_cycle

  def reporting
    render json: StatisticService.reporting(recruitment_cycle: @recruitment_cycle)
  end

private

  def build_recruitment_cycle
    @recruitment_cycle = RecruitmentCycle.find_by(
      year: params[:recruitment_cycle_year],
    ) || RecruitmentCycle.current_recruitment_cycle
  end
end
