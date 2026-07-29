# frozen_string_literal: true

module Publish
  module Schools
    # Explains why the school list is shorter than the provider's account.
    # Providers told us in research that they could not find schools they
    # expected, so the two things they can act on are spelled out: the school
    # may not be in their account, or its GIAS record may be wrong.
    class PhaseFilterCalloutComponent < ViewComponent::Base
      def initialize(provider:, level:, out_of_phase_schools: false)
        @provider = provider
        @level = level.to_s
        @out_of_phase_schools = out_of_phase_schools

        super()
      end

      # Nothing to explain when we are not filtering.
      def render?
        GiasSchool::PHASE_CODES_FOR_COURSE_LEVEL.key?(@level)
      end

      # The strict wording is only true while every listed school matches the
      # level. A rolled over course can still hold an out-of-phase school,
      # which the picker deliberately keeps visible.
      def heading
        return t(".heading.#{@level}") unless @out_of_phase_schools

        t(".heading_with_exceptions.#{@level}")
      end

      def schools_path
        publish_provider_recruitment_cycle_schools_path(
          @provider.provider_code,
          @provider.recruitment_cycle_year,
        )
      end

      def gias_url
        t("publish.providers.schools.index.gias_url")
      end
    end
  end
end
