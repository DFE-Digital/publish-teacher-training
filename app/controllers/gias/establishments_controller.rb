module GIAS
  class EstablishmentsController < GIAS::ApplicationController
    before_action :build_filters, only: :index

    def index
      establishments = GIASEstablishment.all

      establishments = establishments.search_by_name_or_urn(@filters.search) unless @filters.search.blank?

      establishments = establishments.that_match_providers_by_name              if @filters.name.include? 'provider'
      establishments = establishments.that_match_sites_by_name                  if @filters.name.include? 'sites'
      establishments = establishments.that_match_providers_or_sites_by_name     if @filters.name.include? 'provider_or_sites'
      establishments = establishments.that_match_providers_by_postcode          if @filters.postcode.include? 'provider'
      establishments = establishments.that_match_sites_by_postcode              if @filters.postcode.include? 'sites'
      establishments = establishments.that_match_providers_or_sites_by_postcode if @filters.postcode.include? 'provider_or_sites'

      @pagy, @establishments = pagy(establishments.reorder(:id))
    end

    def show
      @establishment = GIASEstablishment.find_by!(urn: params[:urn])
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
