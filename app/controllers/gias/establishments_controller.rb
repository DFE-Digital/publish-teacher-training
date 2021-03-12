module GIAS
  class EstablishmentsController < GIAS::ApplicationController
    before_action :build_filters, only: :index

    def index
      establishments = GIASEstablishment.all

      establishments = establishments.search_by_name_or_urn(@filters.search) if @filters.search.present?

      establishments = establishments.that_match_providers_by_name              if @filters.name.include? "provider"
      establishments = establishments.that_match_sites_by_name                  if @filters.name.include? "sites"
      establishments = establishments.that_match_providers_or_sites_by_name     if @filters.name.include? "provider_or_sites"
      establishments = establishments.that_match_providers_by_postcode          if @filters.postcode.include? "provider"
      establishments = establishments.that_match_sites_by_postcode              if @filters.postcode.include? "sites"
      establishments = establishments.that_match_providers_or_sites_by_postcode if @filters.postcode.include? "provider_or_sites"

      @pagy, @establishments = pagy(establishments.reorder(:id))
    end

    def show
      @establishment = GIASEstablishment.find_by!(urn: params[:urn])
      graph = GIAS::EstablishmentGraphGeneratorService.call(establishment: @establishment)
      graph.output(cmapx: cmapx_filename)
      @graph_cmapx = File.read(cmapx_filename)
    end

    def graph
      @establishment = GIASEstablishment.find_by!(urn: params[:urn])

      # unless File.exist?(png_filename)
        graph = GIAS::EstablishmentGraphGeneratorService.call(establishment: @establishment)
        graph.output(png: png_filename)
      # end

      send_data File.read(png_filename), type: "image/png", disposition: "inline"
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

    def graph_filename
      File.join(Dir.tmpdir, @establishment.name.underscore)
    end

    def png_filename
      "#{graph_filename}.png"
    end

    def cmapx_filename
      "#{graph_filename}.html"
    end
  end
end
