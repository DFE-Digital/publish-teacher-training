module Courses
  module EditOptions
    module AgeRangeConcern
      extend ActiveSupport::Concern
      included do
        # When changing anything here be sure to update the edit_options in the
        # courses factory in manage-courses-frontend:
        #
        # https://github.com/DFE-Digital/manage-courses-frontend/blob/master/spec/factories/courses.rb
        def age_range_options
          case level
          when :primary
            %w[
              3_to_7
              5_to_11
              7_to_11
              7_to_14
            ]
          when :secondary
            %w[
              11_to_16
              11_to_18
              14_to_19
            ]
          end
        end
      end
    end
  end
end
