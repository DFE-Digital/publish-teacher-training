# frozen_string_literal: true

class CourseWizard
  module Steps
    class CheckAnswers
      include DfE::Wizard::Step
      include CourseWizard::Reviewable

      def self.permitted_params
        []
      end
    end
  end
end
