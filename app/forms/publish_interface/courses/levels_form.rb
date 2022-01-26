module PublishInterface
  module Courses
    class LevelsForm < PublishInterface::CourseCreationForm
      FIELDS = %i[
        level
        is_send
      ].freeze

      attr_accessor(*FIELDS)

      validates :level, inclusion: { in: %i[primary secondary further_education], message: "Select a course level" }
    end
  end
end
