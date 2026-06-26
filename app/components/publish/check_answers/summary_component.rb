# frozen_string_literal: true

module Publish
  module CheckAnswers
    class SummaryComponent < ViewComponent::Base
      Row = Struct.new(:label, :value, :change_path, keyword_init: true)

      attr_reader :wizard, :draft

      def initialize(wizard:)
        @wizard = wizard
        @draft = CourseWizard::Draft.new(wizard:)
        super()
      end

      def rows
        @rows ||= review_steps.flat_map { |step|
          step.review_rows(draft)
        }.filter_map do |spec|
          render_row(spec)
        end
      end

      def change_text
        t("course_wizard.steps.check_answers.change")
      end

    private

      def render_row(spec)
        return unless wizard.saved?(spec.step_id) || spec.show_when_blank

        value = format_value(spec)
        row = Row.new(
          label: t_label(spec.label_key, **resolved_label_options(spec)),
          value:,
          change_path: spec.changeable? ? change_path_for(spec.step_id) : nil,
        )
        return row if spec.show_when_blank
        return if !present_value?(spec.value) && !present_value?(value)

        row
      end

      def format_value(spec)
        return spec.value unless spec.format

        spec.format.call(spec.value, draft, self)
      end

      def present_value?(value)
        return false if value.nil?
        return !value.empty? if value.respond_to?(:empty?)

        true
      end

      def change_path_for(step_id)
        wizard.route_strategy.resolve(step_id:, options: { return_to_review: step_id })
      end

      def t_label(key, **options)
        t("course_wizard.steps.check_answers.labels.#{key}", **options)
      end

      def resolved_label_options(spec)
        return spec.label_options unless spec.label_key == :schools && spec.label_options.key?(:employment_based)

        employment_based = spec.label_options.fetch(:employment_based)
        spec.label_options.except(:employment_based).merge(
          prefix: t("course_wizard.steps.check_answers.labels.schools_prefix.#{employment_based ? 'salaried' : 'unsalaried'}"),
        )
      end

    public

      def study_sites_call_to_action_link
        if wizard.provider.study_sites.any?
          govuk_link_to(
            t("course_wizard.steps.check_answers.answers.select_study_site"),
            change_path_for(:study_sites),
          )
        else
          govuk_link_to(
            t("course_wizard.steps.check_answers.answers.add_a_study_site"),
            helpers.publish_provider_recruitment_cycle_study_sites_path(
              wizard.provider_code,
              wizard.recruitment_cycle_year,
            ),
          )
        end
      end

    private

      def review_steps
        @review_steps ||= wizard.review_steps(draft:)
      end
    end
  end
end
