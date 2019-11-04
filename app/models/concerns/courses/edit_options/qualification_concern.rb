module Courses
  module EditOptions
    module QualificationConcern
      extend ActiveSupport::Concern
      included do
        # When changing anything here be sure to update the edit_options in the
        # courses factory in manage-courses-frontend:
        #
        # https://github.com/DFE-Digital/manage-courses-frontend/blob/master/spec/factories/courses.rb
        def qualification_options
          if level == "further_education"
            qualifications_without_qts
          else
            qualifications_with_qts
          end
        end

        def qualifications_with_qts
          Course.qualifications.keys.select do |qualification|
            qualification.include?("qts")
          end
        end

        def qualifications_without_qts
          Course.qualifications.keys.reject do |qualification|
            qualification.include?("qts")
          end
        end
      end
    end
  end
end
