module Find
  module Courses
    module ContentsComponent
      class View < ViewComponent::Base
        attr_reader :course

        delegate :about_course,
          :how_school_placements_work,
          :program_type,
          :provider,
          :about_accrediting_body,
          :salaried?,
          :interview_process, to: :course

        def initialize(course)
          super
          @course = course
        end
      end
    end
  end
end
