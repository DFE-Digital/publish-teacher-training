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
          qualifications_with_qts, qualifications_without_qts = Course::qualifications.keys.partition { |q| q.include?('qts') }
          level == :further_education ? qualifications_without_qts : qualifications_with_qts
        end
      end
    end
  end
end
