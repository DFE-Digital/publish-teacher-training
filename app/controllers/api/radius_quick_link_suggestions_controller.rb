module API
  class RadiusQuickLinkSuggestionsController < PublicAPIController
    def index
      render json: Courses::RadiusQuickLinkSuggestions.new(
        params: params.to_unsafe_h,
        i18n_scope: "api.radius_quick_link_suggestions",
        request_query: request.query_parameters,
      ).call
    end
  end
end
