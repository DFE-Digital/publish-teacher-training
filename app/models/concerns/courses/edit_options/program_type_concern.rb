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
          if self_accredited? && provider.is_it_really_really_a_scitt?
            %i[pg_teaching_apprenticeship scitt_programme]
          elsif self_accredited?
            %i[pg_teaching_apprenticeship higher_education_programme]
          else
            %i[pg_teaching_apprenticeship school_direct_training_programme school_direct_salaried_training_programme]
          end
        end
      end
    end
  end
end
