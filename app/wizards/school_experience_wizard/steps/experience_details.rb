# frozen_string_literal: true

class SchoolExperienceWizard
  module Steps
    class ExperienceDetails
      include DfE::Wizard::Step

      attribute :experience_details, :string

      validates :experience_details, presence: true, words_count: { maximum: 250 }

      def self.permitted_params
        %i[experience_details]
      end
    end
  end
end
