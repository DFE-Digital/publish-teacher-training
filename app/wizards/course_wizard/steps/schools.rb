class CourseWizard
  module Steps
    class Schools
      include DfE::Wizard::Step

      FUNDING_TYPES_WITH_SALARY = %w[salary apprenticeship].freeze

      attribute :site_ids

      validate :site_ids_selected

      def sites
        provider_sites.sort_by(&:location_name)
      end

      def salaried?
        funding_type.in?(FUNDING_TYPES_WITH_SALARY)
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
        provider.sites
      end

      def provider
        @provider ||= recruitment_cycle.providers.find_by!(provider_code: wizard.provider_code)
      end

      def recruitment_cycle
        @recruitment_cycle ||= RecruitmentCycle.find_by!(year: wizard.recruitment_cycle_year)
      end

      def funding_type
        wizard.state_store.funding_type
      end
    end
  end
end
