# frozen_string_literal: true

module Courses
  module EditOptions
    module QualificationConcern
      extend ActiveSupport::Concern
      included do
        def qualification_options
          if level == 'further_education'
            qualifications_without_qts
          else
            qualifications_with_qts
          end
        end

        def qualifications_with_qts
          qts_list = Course.qualifications.keys.grep(/qts/)

          return qts_list if tda_active?

          qts_list - %w[undergraduate_degree_with_qts]
        end

        def qualifications_without_qts
          Course.qualifications.keys.reject do |qualification|
            qualification.include?('qts')
          end
        end
      end
    end
  end
end
