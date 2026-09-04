class CourseWizard
  module Steps
    class Schools
      include DfE::Wizard::Step
      include CourseWizard::Reviewable

      FUNDING_TYPES_WITH_SALARY = %w[salary apprenticeship].freeze
      QUALIFICATIONS_WITH_SALARY = %w[undergraduate_degree_with_qts].freeze

      attribute :school_uuids

      validate :school_uuids_selected
      validate :school_uuids_resolve

      review do |r|
        r.row(
          label: :schools,
          label_options: ->(draft) { { count: draft.schools.count, employment_based: draft.employment_based? } },
          value: ->(draft) { draft.schools.map(&:location_name) },
          show_when_blank: true,
          format: Publish::CheckAnswers::Formatters::List.new(separator: :br),
        )
      end

      def schools
        @schools ||= SchoolsList.for(provider)
      end

      # The schools chosen so far, which is what a change is measured against. Back
      # and the Change link on check answers both re-render this step with those
      # boxes ticked, and they are the baseline rather than a change to it.
      #
      # Read from the store rather than off the step: a failed submit re-hydrates the
      # step from the params, so its own attribute is what was just submitted - the
      # thing being measured, not what to measure it against. Persist does not run
      # when Validate fails, so the store still holds the answer.
      def attached_school_uuids
        Array(wizard.state_store.school_uuids).compact_blank
      end

      def schools_collapse_threshold
        SchoolsList::COLLAPSE_AFTER
      end

      def collapse_schools?
        schools.size > schools_collapse_threshold
      end

      def salaried?
        funding_type.in?(FUNDING_TYPES_WITH_SALARY) || qualification.in?(QUALIFICATIONS_WITH_SALARY)
      end

      def self.permitted_params
        [{ school_uuids: [] }]
      end

    private

      def school_uuids_selected
        self.school_uuids = [schools.first.uuid] if selected_school_uuids.empty? && schools.one?

        return if selected_school_uuids.any?

        errors.add(:school_uuids, I18n.t("course_wizard.steps.schools.errors.school_uuids.blank"))
      end

      # A UUID that does not belong to one of the provider's schools cannot be
      # attached to the course, so reject it here rather than let the wizard
      # carry it through to creation and drop it silently.
      def school_uuids_resolve
        return if selected_school_uuids.empty?

        resolution = ::Schools::UuidResolver.new(
          provider:,
          uuids: selected_school_uuids,
          log_tag: "CourseWizard::Schools",
        )
        return unless resolution.unrecognised?

        errors.add(
          :school_uuids,
          I18n.t("course_schools.errors.unrecognised_school_uuids", support_email: Settings.support_email),
        )
      end

      def selected_school_uuids
        Array(school_uuids).compact_blank
      end

      def provider
        wizard.provider
      end

      def funding_type
        wizard.state_store.funding_type
      end

      def qualification
        wizard.state_store.qualification
      end
    end
  end
end
