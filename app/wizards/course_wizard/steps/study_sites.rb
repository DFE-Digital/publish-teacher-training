# frozen_string_literal: true

class CourseWizard
  module Steps
    class StudySites
      include DfE::Wizard::Step

      attribute :study_sites_ids

      def study_sites
        wizard.provider.study_sites.sort_by(&:location_name)
      end

      def self.permitted_params
        [{ study_sites_ids: [] }]
      end
    end
  end
end
