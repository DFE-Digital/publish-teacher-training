module PublishInterface
  module Courses
    class LevelsForm < PublishInterface::CourseCreationForm
      FIELDS = %i[
        level
      ].freeze

      attr_accessor(*FIELDS)

      validates :level, presence: true

      def stash_or_save
        false
      end
    end
  end
end
