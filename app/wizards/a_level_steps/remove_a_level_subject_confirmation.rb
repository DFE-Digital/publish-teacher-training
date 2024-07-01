# frozen_string_literal: true

module ALevelSteps
  class RemoveALevelSubjectConfirmation < DfE::Wizard::Step
    delegate :course, :exit_path, to: :wizard
    attr_accessor :uuid, :confirmation, :other_subject
    attr_writer :subject

    validates :uuid, presence: true

    validate do |record|
      record.errors.add(:confirmation, :blank, subject: record.subject) if record.confirmation.blank?
    end

    def self.permitted_params
      %i[uuid subject other_subject confirmation]
    end

    def subject
      ALevelSubjectRequirementRowComponent.new(
        subject: @subject,
        other_subject:
      ).subject_name
    end

    def next_step
      if deletion_confirmed? && no_a_level_subject_requirements?
        :exit
      else
        :add_a_level_to_a_list
      end
    end

    def deletion_confirmed?
      confirmation == 'yes'
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
