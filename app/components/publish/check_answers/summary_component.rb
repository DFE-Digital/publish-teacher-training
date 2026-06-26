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
        @rows ||= wizard.flow_steps.flat_map { |step|
          step.respond_to?(:review_rows) ? step.review_rows(draft) : []
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
          label: t_label(spec.label_key, **spec.label_options),
          value:,
          change_path: spec.changeable? ? change_path_for(spec.step_id) : nil,
        )
        return row if spec.show_when_blank
        return if !present_value?(spec.value) && !present_value?(value)

        row
      end

      def format_value(spec)
        return spec.value unless spec.formatter

        formatter(spec.formatter).call(spec.value, draft)
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

      def formatter(key)
        @formatters ||= {
          level: Formatters::LevelFormatter.new(context: self),
          send: Formatters::SendFormatter.new(context: self),
          qualification: Formatters::QualificationFormatter.new(context: self),
          funding: Formatters::FundingFormatter.new(context: self),
          age_range: Formatters::AgeRangeFormatter.new(context: self),
          study_pattern: Formatters::StudyPatternFormatter.new(context: self),
          subjects: Formatters::SubjectsFormatter.new(context: self),
          schools: Formatters::SitesFormatter.new(context: self, separator: "<br>"),
          study_sites: Formatters::StudySitesFormatter.new(context: self),
          visa_deadline: Formatters::VisaDeadlineFormatter.new(context: self),
          sponsor: Formatters::SponsorFormatter.new(context: self),
          yes_no: Formatters::YesNoFormatter.new(context: self),
        }
        @formatters.fetch(key)
      end
    end
  end
end
