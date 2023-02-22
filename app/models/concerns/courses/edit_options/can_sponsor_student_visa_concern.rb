# frozen_string_literal: true

module Courses
  module EditOptions
    module CanSponsorStudentVisaConcern
      extend ActiveSupport::Concern
      included do
        def can_sponsor_student_visa_options
          [true, false]
        end
      end
    end
  end
end
