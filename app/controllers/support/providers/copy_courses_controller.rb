# frozen_string_literal: true

module Support
  module Providers
    class CopyCoursesController < SupportController
      before_action :recruitment_cycle
      def new
        @provider = Provider.find(params[:provider_id])
      end

      def create
        @provider = Provider.find(params[:provider_id])
        @from_provider = recruitment_cycle.providers.find_by(provider_code: params[:course][:autocompleted_provider_code])

        sites_copy_to_course = params[:sites] ? Sites::CopyToCourseService : -> {}

        copier = ::Courses::CopyToProviderService.new(sites_copy_to_course:, enrichments_copy_to_course: Enrichments::CopyToCourseService.new, force: true)

        Provider.transaction do
          @from_provider.courses.map do |course|
            copier.execute(course:, new_provider: @provider)
          end
        end

        redirect_to support_recruitment_cycle_provider_path(recruitment_cycle.year, @provider.id)
      end
    end
  end
end
