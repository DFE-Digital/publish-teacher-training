# frozen_string_literal: true

class CourseWizard
  module Steps
    # The edit review of an edit of a published course: the user confirms
    # that the changes go live. It has no answers.
    class ConfirmChanges
      include DfE::Wizard::Step

      def self.permitted_params
        []
      end
    end
  end
end
