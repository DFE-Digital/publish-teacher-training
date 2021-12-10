module API
  module Public
    module V1
      class ProviderSuggestionsController < API::Public::V1::ApplicationController
        def index
          return render_json_error(status: 400, message: I18n.t("provider_suggestion.errors.bad_request")) if invalid_query?

          found_providers = recruitment_cycle.providers
                              .with_findable_courses
                              .provider_search(params[:query])
                              .limit(10)

          render(
            jsonapi: found_providers,
            class: { Provider: SerializableProviderSuggestion },
          )
        end

      private

        def recruitment_cycle
          @recruitment_cycle = RecruitmentCycle.find_by(
            year: params[:recruitment_cycle_year],
          ) || RecruitmentCycle.current_recruitment_cycle
        end

        def invalid_query?
          params[:query].nil? || params[:query].length < 3
        end
      end
    end
  end
end
