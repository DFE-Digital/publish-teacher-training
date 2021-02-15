class GIASController < GIAS::ApplicationController
  def dashboard
    @current_recruitment_cycle = RecruitmentCycle.current
    @establishments = GIASEstablishment
    @establishments_that_match_any_name = @establishments.that_match_providers_or_sites_by_name
    @establishments_that_match_provider_name = @establishments.that_match_providers_by_name
    @establishments_that_match_site_name = @establishments.that_match_sites_by_name
    @establishments_that_match_any_postcode = @establishments.that_match_providers_or_sites_by_postcode
    @establishments_that_match_provider_postcode = @establishments.that_match_providers_by_postcode
    @establishments_that_match_site_postcode = @establishments.that_match_sites_by_postcode

    @providers = @current_recruitment_cycle.providers
    @providers_with_any_name_match = @providers.with_establishments_that_match_any_name
    @providers_that_match_by_name = @providers.that_match_establishments_by_name
    @providers_with_sites_that_match_by_name = @providers.with_sites_that_match_establishments_by_name
    @providers_with_any_postcode_match = @providers.with_establishments_that_match_any_postcode
    @providers_that_match_by_postcode = @providers.that_match_establishments_by_postcode
    @providers_with_sites_that_match_by_postcode = @providers.with_sites_that_match_establishments_by_postcode
  end

  def import_establishments
    GIAS::EdubaseImporterService.call

    redirect_to gias_dashboard_path
  end
end
