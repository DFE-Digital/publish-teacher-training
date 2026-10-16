# frozen_string_literal: true

class CourseWizard
  module Steps
    class StudySites
      include DfE::Wizard::Step
      include CourseWizard::Reviewable

      attribute :study_sites_ids

      # Picking none shows the prompt to select a study site, like any other
      # blank row. A provider with no study sites at all skips the step, so
      # their prompt links to the study sites page on the organisation instead.
      review do |r|
        r.row(
          label: :study_site,
          label_options: ->(draft) { { count: draft.selected_study_site_ids.count } },
          value: ->(draft) { draft.study_sites.map(&:location_name) },
          format: Publish::CheckAnswers::Formatters::StudySites.new,
          show_when_blank: true,
          changeable: ->(draft) { draft.wizard.provider.study_sites.any? },
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
