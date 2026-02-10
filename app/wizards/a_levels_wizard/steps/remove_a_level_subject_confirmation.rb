# frozen_string_literal: true

class ALevelsWizard
  module Steps
    class RemoveALevelSubjectConfirmation
      include DfE::Wizard::Step

      attribute :uuid, :string
      attribute :confirmation, :string

      validates :uuid, presence: true

      validate do |record|
        record.errors.add(:confirmation, :blank, subject: record.subject) if record.confirmation.blank?
      end

      def self.permitted_params
        %i[uuid confirmation]
      end

      def subject
        wizard.state_store.subject
      end
    end
  end
end
