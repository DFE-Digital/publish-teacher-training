module API
  module V3
    class ProviderSuggestionsController < API::V3::ApplicationController
      before_action :build_recruitment_cycle

      def index
        return render(status: :bad_request) if params[:query].nil? || params[:query].length < 3
        return render(status: :bad_request) unless begins_with_alphanumeric(params[:query])

        providers_ids = @recruitment_cycle.courses.findable.distinct.pluck(:provider_id)
        accrediting_provider_codes = @recruitment_cycle.courses.findable.distinct.pluck(:accrediting_provider_code).compact

        found_providers = @recruitment_cycle.providers
                              .where(provider_code: accrediting_provider_codes)
                              .or(@recruitment_cycle.providers.where(id: providers_ids))
                              .search_by_code_or_name(params[:query])
                              .limit(10)

        render(
          jsonapi: found_providers,
          class: { Provider: SerializableProvider },
        )
      end

    private

      def begins_with_alphanumeric(string)
        string.match?(/^[[:alnum:]].*$/)
      end
    end
  end
end
