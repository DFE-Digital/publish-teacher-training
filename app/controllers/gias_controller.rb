class GIASController < GIAS::ApplicationController
  def dashboard
    @current_recruitment_cycle = RecruitmentCycle.current
    @providers = @current_recruitment_cycle.providers
    @establishments = GIASEstablishment.all
    @providers_that_match_by_postcode = @providers.that_match_establishments_by_postcode
    @providers_with_sites_that_match_by_postcode = @providers.with_sites_that_match_establishments_by_postcode
    @providers_that_match_by_name = @providers.that_match_establishments_by_name
    @providers_with_sites_that_match_by_name = @providers.with_sites_that_match_establishments_by_name
    @providers_with_any_name_match = @providers.with_establishments_that_match_any_name
    @providers_with_any_postcode_match = @providers.with_establishments_that_match_any_postcode
  end

  def import_establishments
    GIAS::EdubaseImporterService.call

    redirect_to gias_path
  end
end
