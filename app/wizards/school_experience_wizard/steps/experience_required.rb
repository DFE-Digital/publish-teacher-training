# frozen_string_literal: true

class SchoolExperienceWizard
  module Steps
    class ExperienceRequired
      include DfE::Wizard::Step

      attribute :experience_required, :boolean

      def self.permitted_params
        %i[experience_required]
      end
    end
  end
end
