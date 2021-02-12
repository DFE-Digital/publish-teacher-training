module GIAS
  class ProvidersController < GIAS::ApplicationController
    def index
      recruitment_cycle = RecruitmentCycle.current
      @pagy, @providers = pagy(recruitment_cycle.providers.all)
    end

    def index_of_providers_that_match_by_postcode
      recruitment_cycle = RecruitmentCycle.current
      providers_scope = recruitment_cycle
                          .providers
                          .joins(:establishments_matched_by_postcode)
                          .distinct
      @pagy, @providers = pagy(providers_scope)

      render :index
    end

    def index_of_providers_with_sites_that_match_by_postcode
      recruitment_cycle = RecruitmentCycle.current
      providers_scope = recruitment_cycle
                          .providers
                          .joins(sites: [:establishments_matched_by_postcode])
                          .distinct
      @pagy, @providers = pagy(providers_scope)

      render :index
    end

    def index_of_providers_that_match_by_name
      recruitment_cycle = RecruitmentCycle.current
      providers_scope = recruitment_cycle
                          .providers
                          .joins(:establishments_matched_by_name)
                          .distinct
      @pagy, @providers = pagy(providers_scope)

      render :index
    end

    def index_of_providers_with_sites_that_match_by_name
      recruitment_cycle = RecruitmentCycle.current
      providers_scope = recruitment_cycle
                          .providers
                          .joins(sites: [:establishments_matched_by_name])
                          .distinct
      @pagy, @providers = pagy(providers_scope)

      render :index
    end

    def show
      @provider = Provider.find(params[:id])

      @matches = GIAS::ProviderMatcherService.call(
        provider: @provider
      )
    end
  end
end
