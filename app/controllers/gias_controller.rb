class GIASController < GIAS::ApplicationController
  def dashboard
    @current_recruitment_cycle = RecruitmentCycle.current
    @providers = @current_recruitment_cycle.providers
    @establishments = GIASEstablishment.all
    @providers_that_match_by_postcode = @providers.joins(:establishments_matched_by_postcode).distinct
    @providers_with_sites_that_match_by_postcode =
      @providers.joins(:sites).joins(:establishments_matched_by_postcode).distinct
    @providers_that_match_by_name = @providers.joins(:establishments_matched_by_name).distinct
  end

  def import_establishments
    GIAS::EdubaseImporterService.call

    redirect_to gias_path
  end
end
