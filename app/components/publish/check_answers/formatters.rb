# frozen_string_literal: true

module Publish
  module CheckAnswers
    module Formatters
      class Enum
        def initialize(scope:, suffix: ".label", value_key_overrides: {}, translation_key_overrides: {})
          @scope = scope
          @suffix = suffix
          @value_key_overrides = value_key_overrides
          @translation_key_overrides = translation_key_overrides
        end

        def call(value, _draft, _view)
          return if value.blank?

          translated_key = @translation_key_overrides[value.to_s]
          return I18n.t(translated_key) if translated_key.present?

          translation_value = @value_key_overrides.fetch(value.to_s, value.to_s)
          I18n.t("#{@scope}.#{translation_value}#{@suffix}", default: value.to_s.humanize)
        end
      end

      class Bool
        def initialize(yes_key:, no_key:)
          @yes_key = yes_key
          @no_key = no_key
        end

        def call(value, _draft, _view)
          key = ActiveModel::Type::Boolean.new.cast(value) ? @yes_key : @no_key
          I18n.t(key)
        end
      end

      class List
        def initialize(separator: ", ")
          @separator = separator
        end

        def call(value, _draft, view)
          return if value.blank?

          escaped = value.map { |entry| ERB::Util.html_escape(entry) }
          @separator == :br ? view.safe_join(escaped, view.tag.br) : value.join(@separator)
        end
      end

      class AgeRange
        def call(value, draft, _view)
          return if value.blank?
          return format_other(draft) if value == "other"

          I18n.t(
            "course_wizard.steps.age_range.options.#{value}.label",
            default: value.to_s.humanize,
          )
        end

      private

        def format_other(draft)
          return "other" if draft.course_age_range_in_years_other_from.blank? || draft.course_age_range_in_years_other_to.blank?

          I18n.t(
            "course_wizard.steps.age_range.other_range_format",
            from: draft.course_age_range_in_years_other_from,
            to: draft.course_age_range_in_years_other_to,
          )
        end
      end

      class StudyPattern
        def call(_value, draft, _view)
          patterns = draft.study_patterns_for_display
          return if patterns.blank?
          return I18n.t("course_wizard.steps.check_answers.answers.full_time_or_part_time") if patterns.sort == %w[full_time part_time]

          patterns.map { |pattern|
            I18n.t(
              "course_wizard.steps.study_pattern.options.#{pattern}.label",
              default: pattern.humanize,
            )
          }.join(", ")
        end
      end

      class StudySites
        def call(value, _draft, view)
          return value.join(", ") if value.present?

          view.study_sites_call_to_action_link
        end
      end

      class VisaDeadline
        def call(_value, draft, _view)
          draft.visa_deadline.to_formatted_string
        end
      end
    end
  end
end
