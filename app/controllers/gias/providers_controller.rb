module GIAS
  class ProvidersController < GIAS::ApplicationController
    before_action :build_filters, only: :index

    def index
      recruitment_cycle = RecruitmentCycle.current
      providers = recruitment_cycle.providers

      providers = providers.search_by_code_or_name(@filters.search) if @filters.search.present?

      if @filters.name_and_postcode&.include? "provider"
        providers = providers
                      .joins(:establishments_matched_by_postcode)
                      .joins(:establishments_matched_by_name)
                      .where('"gias_establishment_provider_postcode_matches"."establishment_id" = "gias_establishment_provider_name_matches"."establishment_id"')
      end
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

      graph = GIAS::ProviderGraphGeneratorService.call(provider: @provider)
      graph.output(cmapx: cmapx_filename)
      @graph_cmapx = File.read(cmapx_filename)

    end

    def graph
      @provider = Provider.find(params[:id])

      # unless File.exist?(png_filename)
        @graph = GIAS::ProviderGraphGeneratorService.call(provider: @provider)
        @graph.output(png: png_filename)
      # end

      send_data File.read(png_filename), type: "image/png", disposition: "inline"
    end

  private

    def build_filters
      @filters = OpenStruct.new(
        name_and_postcode: params.dig(:filters, :name_and_postcode) || [],
        name:              params.dig(:filters, :name) || [],
        postcode:          params.dig(:filters, :postcode) || [],
        search:            params.dig(:filters, :search),
      )

      @filter_object = OpenStruct.new(
        name_and_postcode: @filters.name_and_postcode.reject(&:blank?),
        name: @filters.name.reject(&:blank?),
        postcode: @filters.postcode.reject(&:blank?),
        search: @filters.search,
      )
    end

    def graph_filename
      @graph_filename ||= File.join(Dir.tmpdir, @provider.provider_name.underscore)
    end

    def png_filename
      "#{graph_filename}.png"
    end

    def cmapx_filename
      "#{graph_filename}.html"
    end

  end
end
