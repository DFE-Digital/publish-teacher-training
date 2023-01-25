module Find
  class LocationFilterForm
    NO_OPTION = nil
    LOCATION_OPTION = "1".freeze
    PROVIDER_OPTION = "3".freeze

    attr_reader :params, :errors

    def initialize(params)
      @params = params
      @errors = []
    end

    def valid?
      validate
      @errors.empty?
    end

  private

    def validate
      case selected_option
      when NO_OPTION
        @errors = [I18n.t("find.location_filter.errors.no_option")]
      when LOCATION_OPTION
        if location_query.blank?
          @errors = [I18n.t("find.fields.location"), I18n.t("find.location_filter.errors.missing_location")]
        else
          handle_location_option
        end
      when PROVIDER_OPTION
        @errors = [I18n.t("find.location_filter.errors.blank_provider")] if provider_query.blank? || provider_query == "Select a provider"
      end
    end

    def handle_location_option
      geocode_params = geocode_params_for(location_query)
      if geocode_params
        @params.merge!(geocode_params)
        @valid = true
      else
        @errors = [I18n.t("find.location_filter.fields.location"), I18n.t("find.location_filter.errors.unknown_location")]
      end
    end

    def geocode_params_for(query)
      results = Geocoder.search(query, components: "country:UK").first
      return unless results

      {
        latitude: results.latitude,
        longitude: results.longitude,
        loc: results.address,
        lq: location_query,
        c: country(results),
      }
    end

    def selected_option
      @params[:l]
    end

    def location_query
      @params[:lq]
    end

    def provider_query
      @params["provider.provider_name"]
    end

    def search_radius
      @params[:radius]
    end

    def country(results)
      flattened_results = results.address_components.map(&:values).flatten
      countries = [DEVOLVED_NATIONS, "England"].flatten

      countries.each { |country| return country if flattened_results.include?(country) }
    end
  end
end
