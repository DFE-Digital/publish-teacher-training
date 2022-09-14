module Find
  module Search
    class LocationsController < Find::ApplicationController
      include FilterParameters

      before_action :build_results_filter_query_parameters

      def index
        providers
        @courses_by_location_or_training_provider_form = CoursesByLocationOrTrainingProviderForm.new
      end

      def create
        @courses_by_location_or_training_provider_form = CoursesByLocationOrTrainingProviderForm.new(params: find_courses_by_location_or_training_provider_form_params)

        if @courses_by_location_or_training_provider_form.valid?
          redirect_to find_age_groups_path
        else
          providers
          render :index
        end
      end

    private

      def providers
        @providers ||= RecruitmentCycle.current.providers.by_name_ascending
      end

      def find_courses_by_location_or_training_provider_form_params
        params[:find_courses_by_location_or_training_provider_form]
          .permit(:find_courses,
            :city_town_postcode_query,
            :school_uni_or_provider_query)
      end

      def build_results_filter_query_parameters
        @results_filter_query_parameters = merge_previous_parameters(
          ResultsView.new(query_parameters: request.query_parameters).query_parameters_with_defaults,
        )
      end
    end
  end
end
