# frozen_string_literal: true

class SchoolExperienceWizard
  module Steps
    class ExperienceRequired
      include DfE::Wizard::Step

      attribute :experience_required, :string

      validates :experience_required, presence: true

      def self.permitted_params
        %i[experience_required]
      end
    end
  end
end
