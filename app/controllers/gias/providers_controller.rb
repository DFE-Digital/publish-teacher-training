module GIAS
  class ProvidersController < GIAS::ApplicationController
    def index
      recruitment_cycle = RecruitmentCycle.current
      @pagy, @providers = pagy(recruitment_cycle.providers.all)

      @match_data = {}

      @providers.each do |provider|
        @match_data[provider.id] = GIASMatchers::ProviderService.call(
          provider: provider
        ) || []
      end
    end

    def show
      @provider = Provider.find(params[:id])

      @matches = GIASMatchers::ProviderService.call(
        provider: @provider
      )
    end
  end
end
