module API
  module V3
    class ProviderSuggestionsController < API::V3::ApplicationController
      before_action :build_recruitment_cycle

      def index
        return render(status: :bad_request) if params[:query].nil? || params[:query].length < 3
        return render(status: :bad_request) unless begins_with_alphanumeric(params[:query])

        found_providers = @recruitment_cycle.providers
                              .search_by_code_or_name(params[:query])
                              .limit(10)

        render(
          jsonapi: found_providers,
          class: { Provider: SerializableProviderSuggestion },
        )
      end

    private

      def begins_with_alphanumeric(string)
        string.match?(/^[[:alnum:]].*$/)
      end
    end
  end
end
