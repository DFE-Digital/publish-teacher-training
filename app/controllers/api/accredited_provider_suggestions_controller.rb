# frozen_string_literal: true

module API
  class AccreditedProviderSuggestionsController < PublicAPIController
    def index
      return render_json_error(status: 400, message: I18n.t('accredited_provider_suggestion.errors.bad_request')) if invalid?

      render json: results
    end

    private

    def accredited_provider_search_form = AccreditedProviderSearchForm.new(query:)

    def results = AccreditedProviders::SearchService.call(query:)

    delegate :invalid?, to: :accredited_provider_search_form

    def query = params[:query]
  end
end
