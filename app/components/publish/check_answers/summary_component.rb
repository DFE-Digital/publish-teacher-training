# frozen_string_literal: true

module Publish
  module CheckAnswers
    class SummaryComponent < ViewComponent::Base
      Row = Struct.new(:label, :value, :change_path, keyword_init: true)

      DEFAULT_STEP_ORDER = %i[
        level
        primary_subjects
        secondary_subjects
        physics_specialisms
        age_range
        qualifications
        funding_type
        study_pattern
        schools
        study_sites
        accredited_provider
        visa_sponsorship
        skilled_worker_visa
        visa_sponsorship_application_deadline_required
        visa_sponsorship_application_deadline_at
        start_date
      ].freeze

      attr_reader :wizard, :draft

      def initialize(wizard:)
        @wizard = wizard
        @draft = CourseWizard::Draft.new(wizard:)
        super()
      end

      def rows
        @rows ||= step_ids.flat_map { |step_id| rows_for_step(step_id) }.compact
      end

      def change_text
        t("course_wizard.steps.check_answers.change")
      end

    private

      def rows_for_step(step_id)
        case step_id
        when :level
          [level_row, send_row]
        when :primary_subjects, :secondary_subjects
          [subjects_row(step_id)]
        when :physics_specialisms
          [engineers_teach_physics_row]
        when :age_range
          [saved_value_row(step_id, label: t_label("age_range"), value: draft.age_range_choice, formatter: age_range_formatter)]
        when :qualifications
          [saved_value_row(step_id, label: t_label("qualification"), value: draft.qualification, formatter: qualification_formatter)]
        when :funding_type
          [saved_value_row(step_id, label: t_label("funding_type"), value: draft.funding, formatter: funding_formatter, show_when_blank: true, changeable: !draft.tda?)]
        when :study_pattern
          [saved_value_row(step_id, label: t_label("study_pattern"), value: draft.study_patterns_for_display, formatter: study_pattern_formatter, show_when_blank: true, changeable: !draft.tda?)]
        when :schools
          [schools_row]
        when :study_sites
          [study_sites_row]
        when :accredited_provider
          [accredited_provider_row]
        when :visa_sponsorship
          [saved_value_row(step_id, label: t_label("student_visas"), value: draft.can_sponsor_student_visa, formatter: sponsor_formatter)]
        when :skilled_worker_visa
          [skilled_worker_visa_row]
        when :visa_sponsorship_application_deadline_required
          [saved_value_row(step_id, label: t_label("is_there_a_visa_sponsorship_deadline"), value: draft.visa_sponsorship_application_deadline_required, formatter: yes_no_formatter, show_when_blank: true)]
        when :visa_sponsorship_application_deadline_at
          [saved_value_row(step_id, label: t_label("visa_sponsorship_application_deadline_date"), value: draft.visa_deadline, formatter: visa_deadline_formatter)]
        when :start_date
          [saved_value_row(step_id, label: t_label("start_date"), value: draft.start_date)]
        else
          []
        end
      end

      def level_row
        saved_value_row(
          :level,
          label: t_label("level"),
          value: draft.level,
          formatter: level_formatter,
          changeable: false,
        )
      end

      def send_row
        saved_value_row(
          :level,
          label: t_label("send"),
          value: draft.is_send,
          formatter: send_formatter,
          changeable: false,
        )
      end

      def subjects_row(step_id)
        return unless step_id == subject_step_for_level

        names = draft.subjects.map(&:subject_name)
        return if names.blank?

        Row.new(
          label: t_label("subjects", count: names.count),
          value: subjects_formatter.call(names, draft),
          change_path: change_path_for(step_id),
        )
      end

      def subject_step_for_level
        return :primary_subjects if draft.state_store.primary_level?
        return :secondary_subjects unless draft.state_store.further_education_level?

        nil
      end

      def engineers_teach_physics_row
        return unless wizard.saved?(:physics_specialisms)

        value = draft.campaign_name == "engineers_teach_physics"
        Row.new(
          label: t_label("engineers"),
          value: yes_no_formatter.call(value, draft),
          change_path: change_path_for(:physics_specialisms),
        )
      end

      def schools_row
        return unless wizard.saved?(:schools)
        return unless present_value?(draft.school_ids)

        Row.new(
          label: school_label_with_plural(count: draft.schools.count),
          value: schools_formatter.call(draft.schools.map(&:location_name), draft),
          change_path: change_path_for(:schools),
        )
      end

      def study_sites_row
        count = draft.selected_study_site_ids.count
        value = if count.positive?
                  study_sites_formatter.call(draft.study_sites.map(&:location_name), draft)
                else
                  study_sites_call_to_action_link
                end

        Row.new(
          label: t_label("study_site", count:),
          value:,
          change_path: count.positive? ? change_path_for(:study_sites) : nil,
        )
      end

      def accredited_provider_row
        provider = draft.accrediting_provider
        return if provider.blank?

        Row.new(
          label: t_label("accredited_provider"),
          value: provider.provider_name,
          change_path: wizard.saved?(:accredited_provider) ? change_path_for(:accredited_provider) : nil,
        )
      end

      def skilled_worker_visa_row
        return unless draft.employment_based?

        saved_value_row(
          :skilled_worker_visa,
          label: t_label("skilled_worker_visas"),
          value: draft.can_sponsor_skilled_worker_visa,
          formatter: sponsor_formatter,
          show_when_blank: true,
          changeable: !draft.tda?,
        )
      end

      def saved_value_row(step_id, label:, value:, formatter: nil, show_when_blank: false, changeable: true)
        return unless wizard.saved?(step_id) || show_when_blank

        formatted_value = formatter ? formatter.call(value, draft) : value
        row = Row.new(
          label:,
          value: formatted_value,
          change_path: changeable ? change_path_for(step_id) : nil,
        )
        return row if show_when_blank
        return if !present_value?(value) && !present_value?(formatted_value)

        row
      end

      def present_value?(value)
        return false if value.nil?
        return !value.empty? if value.respond_to?(:empty?)

        true
      end

      def change_path_for(step_id)
        wizard.route_strategy.resolve(step_id:, options: { return_to_review: step_id })
      end

      def school_label_with_plural(count:)
        prefix = t("course_wizard.steps.check_answers.labels.schools_prefix.#{draft.employment_based? ? 'salaried' : 'unsalaried'}")
        t_label("schools", count:, prefix:)
      end

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

      def t_label(key, **options)
        t("course_wizard.steps.check_answers.labels.#{key}", **options)
      end

      def step_ids
        ids = flow_path_step_ids
        return DEFAULT_STEP_ORDER if ids.blank?

        (ids & DEFAULT_STEP_ORDER) + (DEFAULT_STEP_ORDER - ids)
      end

      def flow_path_step_ids
        return [] unless wizard.respond_to?(:flow_path)

        Array(wizard.flow_path).filter_map { |step|
          extract_step_id(step)
        }.uniq
      end

      def extract_step_id(step)
        return step.to_sym if step.respond_to?(:to_sym)
        return step.step_id.to_sym if step.respond_to?(:step_id)
        return step.id.to_sym if step.respond_to?(:id)

        nil
      rescue NoMethodError
        nil
      end

      def level_formatter
        @level_formatter ||= lambda do |value, _draft|
          I18n.t("course_wizard.steps.level.options.#{value}", default: value)
        end
      end

      def send_formatter
        @send_formatter ||= lambda do |value, _draft|
          key = ActiveModel::Type::Boolean.new.cast(value) ? "yes_send" : "no_send"
          I18n.t("course_wizard.steps.level.options.#{key}", default: value)
        end
      end

      def qualification_formatter
        @qualification_formatter ||= lambda do |value, _draft|
          I18n.t("course_wizard.steps.qualifications.options.#{value}.label", default: value)
        end
      end

      def funding_formatter
        @funding_formatter ||= Formatters::FundingFormatter.new(context: self)
      end

      def age_range_formatter
        @age_range_formatter ||= Formatters::AgeRangeFormatter.new(context: self)
      end

      def study_pattern_formatter
        @study_pattern_formatter ||= Formatters::StudyPatternFormatter.new(context: self)
      end

      def subjects_formatter
        @subjects_formatter ||= Formatters::SubjectsFormatter.new(context: self)
      end

      def schools_formatter
        @schools_formatter ||= Formatters::SitesFormatter.new(context: self, separator: "<br>")
      end

      def study_sites_formatter
        @study_sites_formatter ||= Formatters::SitesFormatter.new(context: self)
      end

      def visa_deadline_formatter
        @visa_deadline_formatter ||= Formatters::VisaDeadlineFormatter.new(context: self)
      end

      def sponsor_formatter
        @sponsor_formatter ||= Formatters::SponsorFormatter.new(context: self)
      end

      def yes_no_formatter
        @yes_no_formatter ||= Formatters::YesNoFormatter.new(context: self)
      end
    end
  end
end
