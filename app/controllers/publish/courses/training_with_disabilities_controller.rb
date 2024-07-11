# frozen_string_literal: true

module Publish
  module Courses
    class TrainingWithDisabilitiesController < PublishController
      include CourseBasicDetailConcern
      before_action :build_course, only: %i[show]

      def show; end

      private

      def build_course
        super
        authorize @course
      end
    end
  end
end
