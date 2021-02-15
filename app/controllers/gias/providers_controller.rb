module GIAS
  class ProvidersController < GIAS::ApplicationController
    before_action :build_filters, only: :index

    def index
      recruitment_cycle = RecruitmentCycle.current
      providers = recruitment_cycle.providers

      providers = providers.that_match_establishments_by_postcode            if @filters.postcode.include? 'provider'
      providers = providers.with_sites_that_match_establishments_by_postcode if @filters.postcode.include? 'sites'
      providers = providers.with_establishments_that_match_any_postcode      if @filters.postcode.include? 'provider_or_sites'
      providers = providers.that_match_establishments_by_name                if @filters.name.include? 'provider'
      providers = providers.with_sites_that_match_establishments_by_name     if @filters.name.include? 'sites'
      providers = providers.with_establishments_that_match_any_name          if @filters.name.include? 'provider_or_sites'

      @filter_object = OpenStruct.new(
        name: @filters.name.reject(&:blank?),
        postcode: @filters.postcode.reject(&:blank?),
      )

      @pagy, @providers = pagy(providers)
    end

    def show
      @provider = Provider.find(params[:id])

      @matches = GIAS::ProviderMatcherService.call(
        provider: @provider
      )
    end

    private

    def build_filters
      @filters = OpenStruct.new(
        name:     params.key?(:filters) ? params[:filters].fetch(:name,     []) : [],
        postcode: params.key?(:filters) ? params[:filters].fetch(:postcode, []) : []
      )
    end
  end
end
