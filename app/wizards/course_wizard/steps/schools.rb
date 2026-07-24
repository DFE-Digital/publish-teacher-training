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
          format: Publish::CheckAnswers::Formatters::List.new(separator: :br),
        )
      end

      def schools
        @schools ||= course_school_identity.available_schools
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
        if selected_school_uuids.empty? && course_school_identity.available_schools_count == 1
          self.school_uuids = [course_school_identity.available_schools.first.uuid.to_s]
        end

        return if selected_school_uuids.any?

        errors.add(:school_uuids, I18n.t("course_wizard.steps.schools.errors.school_uuids.blank"))
      end

      def school_uuids_resolve
        return if selected_school_uuids.empty?

        course_school_identity.school_records_for(school_uuids: selected_school_uuids)
      rescue ArgumentError => e
        Rails.logger.warn(
          "[CourseWizard::Schools] invalid school UUIDs for provider=#{wizard.provider.id}: #{e.message}",
        )
        errors.add(:school_uuids, I18n.t("course_wizard.steps.schools.errors.school_uuids.blank"))
      end

      def selected_school_uuids
        Array(school_uuids).compact_blank
      end

      def course_school_identity
        @course_school_identity ||= CourseSchools::Identity.new(provider: wizard.provider)
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
