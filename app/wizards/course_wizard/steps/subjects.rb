# frozen_string_literal: true

class CourseWizard
  module Steps
    class Subjects
      include DfE::Wizard::Step

      def self.permitted_params
        %i[master_subject_id subordinate_subject_id]
      end
    end
  end
end
