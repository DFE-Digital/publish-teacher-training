# frozen_string_literal: true

class CourseWizard
  module Steps
    class CheckAnswers
      include DfE::Wizard::Step

      def self.permitted_params
        []
      end
    end
  end
end
