module Find
  class ApplicationController < ActionController::Base
    layout "find_layout"
    default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

    def index
      @providers = RecruitmentCycle.current.providers.by_name_ascending
      @courses_by_location_or_training_provider_form = CoursesByLocationOrTrainingProviderForm.new
    end
  end
end
