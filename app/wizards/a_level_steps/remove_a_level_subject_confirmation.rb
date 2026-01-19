# frozen_string_literal: true

module ALevelSteps
  class RemoveALevelSubjectConfirmation
    include DfE::Wizard::Step

    attribute :uuid, :string
    attribute :minimum_grade_required, :string
    attribute :confirmation, :string
    attribute :other_subject, :string

    validates :uuid, presence: true

    validate do |record|
      record.errors.add(:confirmation, :blank, subject: record.subject) if record.confirmation.blank?
    end

    def self.permitted_params
      %i[uuid subject other_subject confirmation]
    end

    def subject
      hash = wizard.state_store.repository.record.a_level_subject_requirements.find { it["uuid"] == uuid }

      I18n.t("helpers.label.what_a_level_is_required.subject_options.#{hash.fetch('subject', nil)}")
    end

    def next_step
      if deletion_confirmed? && no_a_level_subject_requirements?
        :exit
      else
        :add_a_level_to_a_list
      end
    end

    def deletion_confirmed?
      confirmation == "yes"
    end

    def no_a_level_subject_requirements?
      a_level_subject_requirements.empty?
    end

  private

    def a_level_subject_requirements
      Array(course.a_level_subject_requirements)
    end
  end
end
