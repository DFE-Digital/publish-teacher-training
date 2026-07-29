class CourseWizard
  module Steps
    class Schools
      include DfE::Wizard::Step
      include CourseWizard::Reviewable

      FUNDING_TYPES_WITH_SALARY = %w[salary apprenticeship].freeze
      QUALIFICATIONS_WITH_SALARY = %w[undergraduate_degree_with_qts].freeze

      attribute :school_uuids

      validate :school_uuids_selected

      review do |r|
        r.row(
          label: :schools,
          label_options: ->(draft) { { count: draft.schools.count, employment_based: draft.employment_based? } },
          value: ->(draft) { draft.schools.map { |school| school.decorate.location_name } },
          format: Publish::CheckAnswers::Formatters::List.new(separator: :br),
        )
      end

      def schools
        @schools ||= identity.available_schools.to_a
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

      def identity
        @identity ||= ::CourseSchools::Identity.new(provider: wizard.provider)
      end

      def school_uuids_selected
        if selected_school_uuids.empty? && schools.one?
          self.school_uuids = [schools.first.uuid.to_s]
        end

        return if selected_school_uuids.any?

        errors.add(:school_uuids, I18n.t("course_wizard.steps.schools.errors.school_uuids.blank"))
      end

      def selected_school_uuids
        Array(school_uuids).compact_blank
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
