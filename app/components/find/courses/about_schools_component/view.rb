# frozen_string_literal: true

module Find
  module Courses
    module AboutSchoolsComponent
      class View < ViewComponent::Base
        include PublishHelper
        include PreviewHelper

        attr_reader :course

        delegate :published_how_school_placements_work,
                 :program_type,
                 :study_sites,
                 :site_statuses, to: :course

        def initialize(course)
          super
          @course = course
        end

        def render?
          published_how_school_placements_work.present? ||
            program_type == 'higher_education_programme' ||
            program_type == 'scitt_programme' ||
            study_sites.any? ||
            site_statuses.map(&:site).uniq.many?
        end
      end
    end
  end
end
