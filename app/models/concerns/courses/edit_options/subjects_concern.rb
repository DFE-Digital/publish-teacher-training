# frozen_string_literal: true

module Courses
  module EditOptions
    module SubjectsConcern
      extend ActiveSupport::Concern
      included do
        def potential_subjects
          assignable_master_subjects&.sort_by(&:subject_name)
        end

        def modern_languages
          ModernLanguagesSubject.all
        end

        def modern_languages_subject
          SecondarySubject.modern_languages
        end

        def design_technologies
          DesignTechnologySubject.all
        end

        def design_technology_subjects
          SecondarySubject.design_technology
        end
      end
    end
  end
end
