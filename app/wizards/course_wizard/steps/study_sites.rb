# frozen_string_literal: true

class CourseWizard
  module Steps
    class StudySites
      include DfE::Wizard::Step

      attribute :study_sites_ids

      def study_sites
        provider.study_sites.sort_by(&:location_name)
      end

      def self.permitted_params
        [{ study_sites_ids: [] }]
      end

    private

      def provider
        @provider ||= recruitment_cycle.providers.find_by!(provider_code: wizard.provider_code)
      end

      def recruitment_cycle
        @recruitment_cycle ||= RecruitmentCycle.find_by!(year: wizard.recruitment_cycle_year)
      end
    end
  end
end
