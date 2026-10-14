# frozen_string_literal: true

module Publish
  module CheckAnswers
    class SummaryComponent < ViewComponent::Base
      Row = Struct.new(:label, :value, :change_path, :id, keyword_init: true)

      attr_reader :wizard, :draft, :errors

      def initialize(wizard:, errors: ActiveModel::Errors.new(nil))
        @wizard = wizard
        @errors = errors
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
        change_path = spec.changeable? ? change_path_for(spec.step_id) : nil
        label = t_label(spec.label_key, **resolved_label_options(spec))
        return blank_row(spec, label, change_path) if spec.show_when_blank && !present_value?(value)

        row = Row.new(label:, value:, change_path:)
        return row if spec.show_when_blank
        return if !present_value?(spec.value) && !present_value?(value)

        row
      end

      # A required question left blank. The row is the prompt to answer it, so
      # the link takes the place of the Change action. The id is where the
      # error summary links to when the user tries to add the course, and the
      # prompt turns red when that question has an error.
      def blank_row(spec, label, change_path)
        Row.new(
          label:,
          id: error_id(spec.step_id),
          value: helpers.value_prompt(
            t("course_wizard.steps.check_answers.prompts.#{spec.label_key}"),
            change_path,
            error: errors.include?(spec.step_id),
          ),
          change_path: nil,
        )
      end

      # Matches the anchor govuk_error_summary builds from the form scope (the
      # current step) and the error's attribute (the unanswered step).
      def error_id(step_id)
        [wizard.current_step_name, step_id, "field-error"].join("-").dasherize
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

      def add_a_study_site_link
        govuk_link_to(
          t("course_wizard.steps.check_answers.answers.add_a_study_site"),
          helpers.publish_provider_recruitment_cycle_study_sites_path(
            wizard.provider_code,
            wizard.recruitment_cycle_year,
          ),
        )
      end

    private

      def review_steps
        @review_steps ||= wizard.review_steps(draft:)
      end
    end
  end
end
