module Courses
  module EditOptions
    module QualificationConcern
      extend ActiveSupport::Concern
      included do
        def qualification_options
          qualifications_with_qts, qualifications_without_qts = Course::qualifications.keys.partition { |q| q.include?('qts') }
          level == :further_education ? qualifications_without_qts : qualifications_with_qts
        end
      end
    end
  end
end
