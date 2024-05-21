# frozen_string_literal: true

module Courses
  module EditOptions
    module StudyModeConcern
      extend ActiveSupport::Concern
      included do
        def study_mode_options
          %w[full_time part_time]
        end
      end
    end
  end
end
