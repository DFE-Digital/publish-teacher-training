module PublishInterface
  module Courses
    class LevelsForm < PublishInterface::CourseCreationForm
      FIELDS = %i[
        course_level
        is_send
      ].freeze

      attr_accessor(*FIELDS)

      validates :course_level, inclusion: { in: %w[primary secondary further_education], message: "Select a course level" }

      def compute_fields
        course.attributes.slice(*FIELDS).merge(params)
      end
    end
  end
end
