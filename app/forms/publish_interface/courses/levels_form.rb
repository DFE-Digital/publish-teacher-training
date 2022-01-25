module PublishInterface
  module Courses
    class LevelsForm < PublishInterface::CourseCreationForm
      FIELDS = %i[
        level
      ].freeze

      attr_accessor(*FIELDS)

      # validates :level, presence: true
    end
  end
end
