module API
  module Public
    module V1
      class ProviderSuggestionsController < API::Public::V1::ApplicationController
        def index
          return render(status: :bad_request) if params[:query].nil? || params[:query].length < 3

          found_providers = recruitment_cycle.providers
                              .with_findable_courses
                              .search_by_code_or_name(params[:query])
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
      end
    end
  end
end
