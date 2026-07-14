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
          label_options: ->(draft) { { count: draft.schools.count, employment_based: draft.employment_based? } },
          value: ->(draft) { draft.schools.map(&:location_name) },
          format: Publish::CheckAnswers::Formatters::List.new(separator: :br),
        )
      end

      # rubocop:disable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
      # TODO School data remodel removal - replace with Provider::School records when the wizard no longer reads provider.sites.
      def sites
        @sites ||= provider_sites.sort_by(&:location_name)
      end

      def schools_collapse_threshold
        SchoolsList::COLLAPSE_AFTER
      end

      def collapse_schools?
        sites.size > schools_collapse_threshold
      end

      def salaried?
        funding_type.in?(FUNDING_TYPES_WITH_SALARY) || qualification.in?(QUALIFICATIONS_WITH_SALARY)
      end

      def self.permitted_params
        [{ site_ids: [] }]
      end

    private

      # TODO School data remodel removal - remove Site-based defaulting when selected schools are Provider::School-backed.
      def site_ids_selected
        if selected_site_ids.empty? && provider_sites.one?
          self.site_ids = [provider_sites.first.uuid]
        end

        return if selected_site_ids.any?

        errors.add(:site_ids, I18n.t("course_wizard.steps.schools.errors.site_ids.blank"))
      end

      def selected_site_ids
        Array(site_ids).compact_blank
      end

      # TODO School data remodel removal - replace with provider schools when school selection no longer uses Site.
      def provider_sites
        wizard.provider.sites
      end

      def funding_type
        wizard.state_store.funding_type
      end
      # rubocop:enable Style/CommentAnnotation, Lint/RedundantCopDisableDirective

      def qualification
        wizard.state_store.qualification
      end
    end
  end
end
