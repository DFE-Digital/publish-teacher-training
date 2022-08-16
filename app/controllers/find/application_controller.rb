module Find
  class ApplicationController < ActionController::Base
    layout "find_layout"
    default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

    def index
      @courses_by_location_or_training_provider_form = CoursesByLocationOrTrainingProviderForm.new
    end
  end
end
