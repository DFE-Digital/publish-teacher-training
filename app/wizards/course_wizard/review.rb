# frozen_string_literal: true

class CourseWizard
  class Review
    Row = Struct.new(:label, :value, :formatted_value, :change_path, :step_id, :attribute, keyword_init: true)

    attr_reader :wizard

    def initialize(wizard)
      @wizard = wizard
    end

    def course_details
      [
        row_for_saved(:level, :level, label: t("labels.level"), changeable: false),
        row_for_saved(:level, :is_send, label: t("labels.send"), changeable: false),
        row_for_saved(:primary_subjects, :primary_master_subject_id, label: t("labels.primary_subject")),
        row_for_saved(:secondary_subjects, :secondary_master_subject_id, label: t("labels.first_subject")),
        row_for_saved(:secondary_subjects, :subordinate_subject_id, label: t("labels.second_subject")),
        row_for_saved(:age_range, :age_range_in_years, label: t("labels.age_range")),
        row_for_saved(:qualifications, :qualification, label: t("labels.qualification")),
        row_for_saved(:funding_type, :funding_type, label: t("labels.funding_type")),
        row_for_saved(:study_pattern, :study_pattern, label: t("labels.study_pattern")),
        row_for_saved(:schools, :site_ids, label: t("labels.schools")),
        row_for_saved(:study_sites, :study_sites_ids, label: t("labels.study_sites")),
        row_for_accrediting_provider,
        row_for_saved(:visa_sponsorship, :can_sponsor_student_visa, label: t("labels.student_visa_sponsorship")),
        row_for_saved(:skilled_worker_visa, :can_sponsor_skilled_worker_visa, label: t("labels.skilled_worker_visa_sponsorship")),
        row_for_saved(:visa_sponsorship_application_deadline_required, :visa_sponsorship_application_deadline_required, label: t("labels.visa_sponsorship_application_deadline_required")),
        row_for_saved(:visa_sponsorship_application_deadline_at, :visa_sponsorship_application_deadline_at, label: t("labels.visa_sponsorship_application_deadline_at")),
        row_for_saved(:start_date, :start_date, label: t("labels.start_date")),
      ].compact
    end

    def format_value(attribute, value)
      case attribute
      when :level
        t("course_wizard.steps.level.options.#{value}", default: value)
      when :is_send
        key = value == "true" ? "yes_send" : "no_send"
        t("course_wizard.steps.level.options.#{key}", default: value)
      when :qualification
        t("course_wizard.steps.qualifications.options.#{value}.label", default: value)
      when :funding_type
        t("course_wizard.steps.funding_type.options.#{value}.label", default: value)
      when :age_range_in_years
        format_age_range(value)
      when :can_sponsor_student_visa, :can_sponsor_skilled_worker_visa, :visa_sponsorship_application_deadline_required
        value ? t("answers.yes") : t("answers.no")
      when :primary_master_subject_id, :secondary_master_subject_id, :subordinate_subject_id
        Subject.find_by(id: value)&.subject_name
      when :site_ids
        Site.where(id: value).pluck(:location_name).join(", ")
      when :study_sites_ids
        Site.where(id: value).pluck(:location_name).join(", ")
      when :accredited_provider_code
        wizard.recruitment_cycle.providers.find_by(provider_code: value)&.provider_name
      when :visa_sponsorship_application_deadline_at
        format_visa_deadline(value)
      when :study_pattern
        Array(value).map { |pattern| t("course_wizard.steps.study_pattern.options.#{pattern}.label", default: pattern.humanize) }.join(", ")
      else
        value
      end
    end

  private

    def row_for_saved(step_id, attribute, **options)
      return unless wizard.saved?(step_id)

      value = wizard.state_store.public_send(attribute)
      changeable = options.fetch(:changeable, true)
      row = Row.new(
        label: options[:label] || attribute.to_s.humanize,
        value:,
        formatted_value: format_value(attribute, value),
        change_path: changeable ? wizard.route_strategy.resolve(step_id:, options: { return_to_review: step_id }) : nil,
        step_id:,
        attribute:,
      )
      return unless present_value?(row.value)

      row
    end

    def row_for_accrediting_provider
      provider = wizard.accrediting_provider
      return if provider.blank?

      change_path = if wizard.saved?(:accredited_provider)
                      wizard.route_strategy.resolve(step_id: :accredited_provider, options: { return_to_review: :accredited_provider })
                    end

      Row.new(
        label: t("labels.accredited_provider"),
        value: provider.provider_code,
        formatted_value: provider.provider_name,
        change_path:,
        step_id: :accredited_provider,
        attribute: :accredited_provider_code,
      )
    end

    def present_value?(value)
      return false if value.nil?
      return !value.empty? if value.respond_to?(:empty?)

      true
    end

    def format_age_range(value)
      return value unless value == "other"
      return value if wizard.state_store.course_age_range_in_years_other_from.blank? || wizard.state_store.course_age_range_in_years_other_to.blank?

      "#{wizard.state_store.course_age_range_in_years_other_from} to #{wizard.state_store.course_age_range_in_years_other_to}"
    end

    def format_visa_deadline(value)
      return if value.blank?
      return value.to_fs(:govuk_date) if value.respond_to?(:to_fs)

      date =
        case value
        when CourseWizard::Steps::VisaSponsorshipApplicationDeadlineAt::DateParts
          Date.new(value.year.to_i, value.month.to_i, value.day.to_i)
        when Hash
          Date.new(value[:year].to_i, value[:month].to_i, value[:day].to_i)
        end

      date&.to_fs(:govuk_date)
    rescue Date::Error
      nil
    end

    def t(key, **options)
      I18n.t("course_wizard.steps.check_answers.#{key}", **options)
    end
  end
end
