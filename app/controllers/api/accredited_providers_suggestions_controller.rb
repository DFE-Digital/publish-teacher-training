# frozen_string_literal: true

module API
  class AccreditedProvidersSuggestionsController < PublicAPIController
    def index
      return render_json_error(status: 400, message: I18n.t('provider_suggestion.errors.bad_request')) if invalid_query?

      accredited_providers = AccreditedProviders::SearchService.call(query: params[:query]).providers
      render json: accredited_providers
    end

    private

    def invalid_query?
      params[:query].nil? || params[:query].length < 3
    end
  end
end
