# frozen_string_literal: true

module Publish
  module CheckAnswers
    module Formatters
      class Base
        def initialize(context:)
          @context = context
        end

      private

        attr_reader :context
      end

      class FundingFormatter < Base
        def call(value, _draft)
          return if value.blank?
          return context.t("course_wizard.steps.check_answers.answers.salary_apprenticeship") if value == "apprenticeship"

          I18n.t("course_wizard.steps.funding_type.options.#{value}.label", default: value)
        end
      end

      class AgeRangeFormatter < Base
        def call(value, draft)
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

      class StudyPatternFormatter < Base
        def call(_value, draft)
          patterns = draft.study_patterns_for_display
          return if patterns.blank?
          return context.t("course_wizard.steps.check_answers.answers.full_time_or_part_time") if patterns.sort == %w[full_time part_time]

          patterns.map { |pattern|
            I18n.t(
              "course_wizard.steps.study_pattern.options.#{pattern}.label",
              default: pattern.humanize,
            )
          }.join(", ")
        end
      end

      class SubjectsFormatter < Base
        def call(value, _draft)
          return if value.blank?

          context.safe_join(value.map { |name| ERB::Util.html_escape(name) }, tag_break)
        end

      private

        def tag_break
          context.tag.br
        end
      end

      class SitesFormatter < Base
        def initialize(context:, separator: ", ")
          super(context:)
          @separator = separator
        end

        def call(value, _draft)
          return if value.blank?

          @separator == "<br>" ? context.safe_join(value, context.tag.br) : value.join(@separator)
        end
      end

      class VisaDeadlineFormatter < Base
        def call(_value, draft)
          draft.visa_deadline.to_formatted_string
        end
      end

      class SponsorFormatter < Base
        def call(value, _draft)
          bool = ActiveModel::Type::Boolean.new.cast(value)
          context.t(bool ? "course_wizard.steps.check_answers.answers.can_sponsor" : "course_wizard.steps.check_answers.answers.cannot_sponsor")
        end
      end

      class YesNoFormatter < Base
        def call(value, _draft)
          bool = ActiveModel::Type::Boolean.new.cast(value)
          context.t(bool ? "course_wizard.steps.check_answers.answers.yes" : "course_wizard.steps.check_answers.answers.no")
        end
      end
    end
  end
end
