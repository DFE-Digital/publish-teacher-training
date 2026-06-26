# frozen_string_literal: true

class CourseWizard
  module Steps
    class StudySites
      include DfE::Wizard::Step
      include CourseWizard::Reviewable

      attribute :study_sites_ids

      review do |r|
        r.row(
          label: :study_site,
          label_options: ->(draft) { { count: draft.selected_study_site_ids.count } },
          value: ->(draft) { draft.study_sites.map(&:location_name) },
          format: Publish::CheckAnswers::Formatters::StudySites.new,
          show_when_blank: true,
          changeable: ->(draft) { draft.selected_study_site_ids.any? },
        )
      end

      def study_sites
        wizard.provider.study_sites.sort_by(&:location_name)
      end

      def self.permitted_params
        [{ study_sites_ids: [] }]
      end
    end
  end
end
