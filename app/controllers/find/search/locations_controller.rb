module Find
  module Search
    class LocationsController < Find::ApplicationController
      def index
        @providers = RecruitmentCycle.current.providers.by_name_ascending
        @courses_by_location_or_training_provider_form = CoursesByLocationOrTrainingProviderForm.new
      end

      def create
        @courses_by_location_or_training_provider_form = CoursesByLocationOrTrainingProviderForm.new(params: find_courses_by_location_or_training_provider_form_params)

        if @courses_by_location_or_training_provider_form.valid?
          redirect_to find_age_groups_path
        else
          @providers = RecruitmentCycle.current.providers.by_name_ascending
          render :index
        end
      end

    private

      def find_courses_by_location_or_training_provider_form_params
        params[:find_courses_by_location_or_training_provider_form]
          .permit(:find_courses,
            :city_town_postcode_query,
            :school_uni_or_provider_query)
      end
    end
  end
end
