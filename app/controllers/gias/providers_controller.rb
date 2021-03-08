module GIAS
  class ProvidersController < GIAS::ApplicationController
    before_action :build_filters, only: :index

    def index
      recruitment_cycle = RecruitmentCycle.current
      providers = recruitment_cycle.providers

      providers = providers.search_by_code_or_name(@filters.search) if @filters.search.present?

      providers = providers.that_match_establishments_by_postcode            if @filters.postcode.include? "provider"
      providers = providers.with_sites_that_match_establishments_by_postcode if @filters.postcode.include? "sites"
      providers = providers.with_establishments_that_match_any_postcode      if @filters.postcode.include? "provider_or_sites"
      providers = providers.that_match_establishments_by_name                if @filters.name.include? "provider"
      providers = providers.with_sites_that_match_establishments_by_name     if @filters.name.include? "sites"
      providers = providers.with_establishments_that_match_any_name          if @filters.name.include? "provider_or_sites"

      @pagy, @providers = pagy(providers.reorder(:id))
    end

    def show
      @provider = Provider.find(params[:id])

      @matches = GIAS::ProviderMatcherService.call(
        provider: @provider,
      )
    end

  private

    def build_filters
      @filters = OpenStruct.new(
        name:     params.dig(:filters, :name) || [],
        postcode: params.dig(:filters, :postcode) || [],
        search:   params.dig(:filters, :search),
      )

      @filter_object = OpenStruct.new(
        name: @filters.name.reject(&:blank?),
        postcode: @filters.postcode.reject(&:blank?),
        search: @filters.search,
      )
    end
  end
end
