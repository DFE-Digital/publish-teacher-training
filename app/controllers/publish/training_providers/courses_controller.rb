module Publish
  module TrainingProviders
    class CoursesController < PublishController
      def index
        authorize(provider, :index?)

        @courses = fetch_courses
      end

    private

      def training_provider
        @training_provider ||= provider.training_providers.find_by(provider_code: params[:training_provider_code])
      end

      def fetch_courses
        training_provider
          .courses
          .includes(:enrichments, :site_statuses, provider: [:recruitment_cycle])
          .where(accredited_body_code: provider.provider_code)
          .order(:name)
          .map(&:decorate)
      end
    end
  end
end
