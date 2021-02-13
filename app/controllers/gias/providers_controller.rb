module GIAS
  class ProvidersController < GIAS::ApplicationController
    before_action :build_filters, only: :index

    def index
      recruitment_cycle = RecruitmentCycle.current
      providers = recruitment_cycle.providers.all

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

    def index_of_providers_with_any_postcode_match
      recruitment_cycle = RecruitmentCycle.current
      @pagy, @providers = pagy recruitment_cycle.providers.with_establishments_that_match_any_postcode

      render :index
    end

    def index_of_providers_that_match_by_postcode
      recruitment_cycle = RecruitmentCycle.current
      @pagy, @providers = pagy recruitment_cycle.providers.that_match_establishments_by_postcode

      render :index
    end

    def index_of_providers_with_sites_that_match_by_postcode
      recruitment_cycle = RecruitmentCycle.current
      @pagy, @providers = pagy recruitment_cycle.providers.with_sites_that_match_establishments_by_postcode

      render :index
    end

    def index_of_providers_with_any_name_match
      recruitment_cycle = RecruitmentCycle.current
      @pagy, @providers = pagy recruitment_cycle.providers.with_establishments_that_match_any_name

      render :index
    end

    def index_of_providers_that_match_by_name
      recruitment_cycle = RecruitmentCycle.current
      @pagy, @providers = pagy recruitment_cycle.providers.that_match_establishments_by_name

      render :index
    end

    def index_of_providers_with_sites_that_match_by_name
      recruitment_cycle = RecruitmentCycle.current
      @pagy, @providers = pagy recruitment_cycle.providers.with_sites_that_match_establishments_by_name

      render :index
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
