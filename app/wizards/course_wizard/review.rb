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
        row_for_subjects,
        row_for_engineers_teach_physics,
        row_for_saved(:age_range, :age_range_in_years, label: t("labels.age_range")),
        row_for_saved(:qualifications, :qualification, label: t("labels.qualification")),
        row_for_saved(:funding_type, :funding_type, label: t("labels.funding_type"), show_when_blank: true, changeable: !teacher_degree_apprenticeship?),
        row_for_saved(:study_pattern, :study_pattern, label: t("labels.study_pattern"), show_when_blank: true, changeable: !teacher_degree_apprenticeship?),
        row_for_schools,
        row_for_study_sites,
        row_for_accrediting_provider,
        row_for_saved(:visa_sponsorship, :can_sponsor_student_visa, label: t("labels.student_visas")),
        row_for_skilled_worker_visa,
        row_for_saved(:visa_sponsorship_application_deadline_required, :visa_sponsorship_application_deadline_required, label: t("labels.is_there_a_visa_sponsorship_deadline")),
        row_for_saved(:visa_sponsorship_application_deadline_at, :visa_sponsorship_application_deadline_at, label: t("labels.visa_sponsorship_application_deadline_date")),
        row_for_saved(:start_date, :start_date, label: t("labels.start_date")),
      ].compact
    end

    def format_value(attribute, value)
      case attribute
      when :level
        I18n.t("course_wizard.steps.level.options.#{value}", default: value)
      when :is_send
        key = ActiveModel::Type::Boolean.new.cast(value) ? "yes_send" : "no_send"
        I18n.t("course_wizard.steps.level.options.#{key}", default: value)
      when :qualification
        I18n.t("course_wizard.steps.qualifications.options.#{value}.label", default: value)
      when :funding_type
        value = "apprenticeship" if value.blank? && teacher_degree_apprenticeship?
        return t("answers.salary_apprenticeship") if value == "apprenticeship"

        I18n.t("course_wizard.steps.funding_type.options.#{value}.label", default: value)
      when :age_range_in_years
        format_age_range(value)
      when :can_sponsor_student_visa, :can_sponsor_skilled_worker_visa
        bool = ActiveModel::Type::Boolean.new.cast(value)
        bool ? t("answers.can_sponsor") : t("answers.cannot_sponsor")
      when :visa_sponsorship_application_deadline_required
        bool = ActiveModel::Type::Boolean.new.cast(value)
        bool ? t("answers.yes") : t("answers.no")
      when :subjects
        value
      when :engineers_teach_physics
        value ? t("answers.yes") : t("answers.no")
      when :primary_master_subject_id, :secondary_master_subject_id, :subordinate_subject_id
        Subject.find_by(id: value)&.subject_name
      when :site_ids
        format_site_names(value, multiline: true)
      when :study_sites_ids
        format_site_names(value)
      when :accredited_provider_code
        wizard.recruitment_cycle.providers.find_by(provider_code: value)&.provider_name
      when :visa_sponsorship_application_deadline_at
        format_visa_deadline(value)
      when :study_pattern
        patterns = Array(value).compact_blank
        patterns = %w[full_time] if patterns.empty? && teacher_degree_apprenticeship?

        if patterns.sort == %w[full_time part_time]
          t("answers.full_time_or_part_time")
        else
          patterns.map { |pattern| I18n.t("course_wizard.steps.study_pattern.options.#{pattern}.label", default: pattern.humanize) }.join(", ")
        end
      else
        value
      end
    end

  private

    def row_for_saved(step_id, attribute, **options)
      return unless wizard.saved?(step_id) || options.fetch(:show_when_blank, false)

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
      return row if options.fetch(:show_when_blank, false)
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

    def row_for_subjects
      subject_ids = selected_subject_ids
      return if subject_ids.blank?

      subject_names_by_id = Subject.where(id: subject_ids).index_by { |subject| subject.id.to_s }
      subject_names = subject_ids.filter_map { |id| subject_names_by_id[id.to_s]&.subject_name }
      return if subject_names.blank?

      Row.new(
        label: t("labels.subjects", count: subject_names.count),
        value: subject_names,
        formatted_value: format_subject_names(subject_names),
        change_path: wizard.route_strategy.resolve(step_id: subject_step_for_level, options: { return_to_review: subject_step_for_level }),
        step_id: subject_step_for_level,
        attribute: :subjects,
      )
    end

    def row_for_engineers_teach_physics
      return unless wizard.saved?(:physics_specialisms)

      value = wizard.state_store.campaign_name == "engineers_teach_physics"
      Row.new(
        label: t("labels.engineers"),
        value:,
        formatted_value: format_value(:engineers_teach_physics, value),
        change_path: wizard.route_strategy.resolve(step_id: :physics_specialisms, options: { return_to_review: :physics_specialisms }),
        step_id: :physics_specialisms,
        attribute: :engineers_teach_physics,
      )
    end

    def row_for_schools
      return unless wizard.saved?(:schools)

      value = wizard.state_store.site_ids
      return unless present_value?(value)

      count = Array(value).compact_blank.count
      Row.new(
        label: school_label_with_plural(count:),
        value:,
        formatted_value: format_value(:site_ids, value),
        change_path: wizard.route_strategy.resolve(step_id: :schools, options: { return_to_review: :schools }),
        step_id: :schools,
        attribute: :site_ids,
      )
    end

    def row_for_study_sites
      value = wizard.state_store.study_sites_ids
      count = Array(value).compact_blank.count
      change_path = if count.positive?
                      wizard.route_strategy.resolve(step_id: :study_sites, options: { return_to_review: :study_sites })
                    end

      Row.new(
        label: t("labels.study_site", count:),
        value:,
        formatted_value: count.positive? ? format_value(:study_sites_ids, value) : study_sites_call_to_action_link,
        change_path:,
        step_id: :study_sites,
        attribute: :study_sites_ids,
      )
    end

    def row_for_skilled_worker_visa
      return unless show_skilled_worker_visa_row?

      row_for_saved(
        :skilled_worker_visa,
        :can_sponsor_skilled_worker_visa,
        label: t("labels.skilled_worker_visas"),
        show_when_blank: true,
        changeable: !teacher_degree_apprenticeship?,
      )
    end

    def present_value?(value)
      return false if value.nil?
      return !value.empty? if value.respond_to?(:empty?)

      true
    end

    def format_age_range(value)
      return if value.blank?
      return I18n.t("course_wizard.steps.age_range.options.#{value}.label") unless value == "other"
      return value if wizard.state_store.course_age_range_in_years_other_from.blank? || wizard.state_store.course_age_range_in_years_other_to.blank?

      I18n.t(
        "course_wizard.steps.age_range.other_range_format",
        from: wizard.state_store.course_age_range_in_years_other_from,
        to: wizard.state_store.course_age_range_in_years_other_to,
      )
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

    def selected_subject_ids
      [
        wizard.state_store.primary_master_subject_id,
        wizard.state_store.secondary_master_subject_id,
        wizard.state_store.subordinate_subject_id,
        *selected_specialism_subject_ids,
      ].compact_blank
    end

    def subject_step_for_level
      wizard.state_store.primary_level? ? :primary_subjects : :secondary_subjects
    end

    def format_site_names(value, multiline: false)
      site_ids = Array(value).compact_blank
      site_names_by_id = Site.where(id: site_ids).index_by { |site| site.id.to_s }
      site_names = site_ids.filter_map { |id| site_names_by_id[id.to_s]&.location_name }
      return site_names.join("<br>").html_safe if multiline

      site_names.join(", ")
    end

    def format_subject_names(subject_names)
      subject_names.join("<br>").html_safe
    end

    def selected_specialism_subject_ids
      specialism_ids = []

      if wizard.state_store.modern_languages_specialisms?
        specialism_ids.concat(Array(wizard.state_store.language_ids))
      end

      if wizard.state_store.design_technology_specialisms?
        specialism_ids.concat(Array(wizard.state_store.design_technology_ids))
      end

      specialism_ids
    end

    def school_label_with_plural(count:)
      prefix = t("labels.schools_prefix.#{salaried_schools? ? 'salaried' : 'unsalaried'}")
      t("labels.schools", count:, prefix:)
    end

    def salaried_schools?
      wizard.state_store.funding_type.in?(%w[salary apprenticeship]) || teacher_degree_apprenticeship?
    end

    def show_skilled_worker_visa_row?
      wizard.state_store.funding_type.in?(%w[salary apprenticeship]) || teacher_degree_apprenticeship?
    end

    def study_sites_call_to_action_link
      href = if wizard.provider.study_sites.any?
               wizard.route_strategy.resolve(step_id: :study_sites, options: { return_to_review: :study_sites })
             else
               Rails.application.routes.url_helpers.publish_provider_recruitment_cycle_study_sites_path(
                 wizard.provider_code,
                 wizard.recruitment_cycle_year,
               )
             end

      link_text = wizard.provider.study_sites.any? ? t("answers.select_study_site") : t("answers.add_a_study_site")
      ActionController::Base.helpers.link_to(link_text, href, class: "govuk-link")
    end

    def teacher_degree_apprenticeship?
      wizard.state_store.qualification == "undergraduate_degree_with_qts"
    end

    def t(key, **options)
      I18n.t("course_wizard.steps.check_answers.#{key}", **options)
    end
  end
end
