module Find
  module Search
    class LocationsController < Find::ApplicationController
      def index
        @providers = RecruitmentCycle.current.providers.by_name_ascending
        @courses_by_location_or_training_provider_form = CoursesByLocationOrTrainingProviderForm.new
      end
    end
  end
end
