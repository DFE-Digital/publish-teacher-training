module Courses
  module EditOptions
    module ProgramTypeConcern
      extend ActiveSupport::Concern
      included do
        # When changing anything here be sure to update the edit_options in the
        # courses factory in manage-courses-frontend:
        #
        # https://github.com/DFE-Digital/manage-courses-frontend/blob/master/spec/factories/courses.rb
        def program_type_options
          if self_accredited?
            %w[Apprenticeship]
          else
            %w[Fee paying (no salary), Salaried, Teaching apprenticeship (with salary)]
          end
        end
      end
    end
  end
end
