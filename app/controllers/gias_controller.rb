class GIASController < GIAS::ApplicationController
  def dashboard
    @current_recruitment_cycle = RecruitmentCycle.current
    @providers = @current_recruitment_cycle.providers
    @providers_with_matching_establishments_by_postcode = @providers.joins(:establishments).uniq
  end

  def import_establishments
    GIAS::EdubaseImporterService.call

    redirect_to gias_path
  end
end
