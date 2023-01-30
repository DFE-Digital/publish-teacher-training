# frozen_string_literal: true

module Find
  module Courses
    module AboutSchoolsComponent
      class View < ViewComponent::Base
        include PublishHelper

        attr_reader :course

        delegate :how_school_placements_work,
                 :program_type,
                 :site_statuses, to: :course

        def initialize(course)
          super
          @course = course
        end

        def render?
          how_school_placements_work.present? ||
            program_type == 'higher_education_programme' ||
            program_type == 'scitt_programme' ||
            site_statuses.map(&:site).uniq.many?
        end
      end
    end
  end
end
