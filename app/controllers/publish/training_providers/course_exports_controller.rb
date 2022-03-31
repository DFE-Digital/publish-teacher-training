module Publish
  module TrainingProviders
    class CourseExportsController < PublishController
      def index
        authorize(provider, :can_list_training_providers?)

        respond_to do |format|
          format.csv do
            send_data(data_export.data, filename: data_export.filename, disposition: :attachment)
          end
        end
      end

    private

      def courses
        @courses ||= provider.current_accredited_courses.includes(:enrichments, :sites, :site_statuses)
      end

      def data_export
        @data_export ||= Exports::AccreditedCourseList.new(courses)
      end
    end
  end
end
