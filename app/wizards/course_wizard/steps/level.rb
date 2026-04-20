# frozen_string_literal: true

class CourseWizard
  module Steps
    class Level
      include DfE::Wizard::Step

      LEVEL_OPTIONS = %w[primary secondary further_education].freeze
      SEND_OPTIONS = %w[true false].freeze

      attribute :level, :string
      attribute :is_send, :string

      validates :level,
                presence: { message: I18n.t("course_wizard.steps.level.errors.level.blank") },
                inclusion: { in: LEVEL_OPTIONS, message: I18n.t("course_wizard.steps.level.errors.level.blank") }
      validates :is_send,
                presence: { message: I18n.t("course_wizard.steps.level.errors.is_send.blank") },
                inclusion: { in: SEND_OPTIONS, message: I18n.t("course_wizard.steps.level.errors.is_send.blank") }

      def self.permitted_params
        %i[level is_send]
      end
    end
  end
end
