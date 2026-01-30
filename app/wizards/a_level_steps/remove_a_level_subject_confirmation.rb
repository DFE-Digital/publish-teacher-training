# frozen_string_literal: true

module ALevelSteps
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
      hash = wizard.state_store.repository.record.find_a_level_subject_requirement!(uuid)

      I18n.t("helpers.label.what_a_level_is_required.subject_options.#{hash.fetch('subject', nil)}")
    end
  end
end
