class CourseWizard
  module Steps
    class Schools
      include DfE::Wizard::Step
      include CourseWizard::Reviewable

      FUNDING_TYPES_WITH_SALARY = %w[salary apprenticeship].freeze
      QUALIFICATIONS_WITH_SALARY = %w[undergraduate_degree_with_qts].freeze

      attribute :site_ids

      validate :site_ids_selected

      review do |r|
        r.row(
          label: :schools,
          label_options: lambda { |draft|
            {
              count: draft.schools.count,
              prefix: I18n.t("course_wizard.steps.check_answers.labels.schools_prefix.#{draft.employment_based? ? 'salaried' : 'unsalaried'}"),
            }
          },
          value: ->(draft) { draft.schools.map(&:location_name) },
          formatter: :schools,
        )
      end

      def sites
        provider_sites.sort_by(&:location_name)
      end

      def salaried?
        funding_type.in?(FUNDING_TYPES_WITH_SALARY) || qualification.in?(QUALIFICATIONS_WITH_SALARY)
      end

      def self.permitted_params
        [{ site_ids: [] }]
      end

    private

      def site_ids_selected
        if selected_site_ids.empty? && provider_sites.one?
          self.site_ids = [provider_sites.first.id.to_s]
        end

        return if selected_site_ids.any?

        errors.add(:site_ids, I18n.t("course_wizard.steps.schools.errors.site_ids.blank"))
      end

      def selected_site_ids
        Array(site_ids).compact_blank
      end

      def provider_sites
        wizard.provider.sites
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
