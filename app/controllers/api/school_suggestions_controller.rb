# frozen_string_literal: true

module API
  class SchoolSuggestionsController < API::Public::V1::ApplicationController
    def index
      return render_json_error(status: 400, message: I18n.t('school_suggestion.errors.bad_request')) if invalid_query?

      schools = Publish::Schools::SearchService.call(query: params[:query]).schools
      render json: schools
    end

    private

    def invalid_query?
      params[:query].nil? || params[:query].length < 3
    end
  end
end
