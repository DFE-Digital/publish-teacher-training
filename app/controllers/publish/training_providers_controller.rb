module Publish
  class TrainingProvidersController < PublishController
    def index
      authorize(provider, :can_list_training_providers?)

      @training_providers = provider.training_providers.include_accredited_courses_counts(provider.provider_code).order(:provider_name)
      @course_counts = @training_providers.to_h { |p| [p.provider_code, p.accredited_courses_count] }
    end
  end
end
