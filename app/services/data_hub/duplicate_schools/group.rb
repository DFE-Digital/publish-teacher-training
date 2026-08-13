# frozen_string_literal: true

module DataHub
  module DuplicateSchools
    # One provider's live school sites sharing a urn, with the GIAS record they
    # all point at and the Provider::School rows they became - the pair the
    # schools list and the course pickers actually read.
    Group = Struct.new(:year, :provider, :urn, :sites, :gias_school, :provider_schools, keyword_init: true) do
      def self.normalise(value)
        value.to_s.strip.downcase.squeeze(" ")
      end

      def kind
        @kind ||= Kind.for(self)
      end

      def codes
        sites.map(&:code).uniq
      end

      def names
        sites.map { |site| Group.normalise(site.location_name) }.uniq
      end

      def gias_name
        Group.normalise(gias_school&.name)
      end

      def main_site
        sites.find { |site| site.code == Provider::School::MAIN_SITE_CODE }
      end

      # What DataHub::Sites::Deduplication::Deduplicator#pick_primary_site would
      # keep, so the report can say whose row that heuristic would discard.
      def legacy_primary
        sites.max_by { |site| [course_ids(site).size, -site.id] }
      end

      def course_ids(site)
        site.site_statuses.map(&:course_id).uniq
      end

      def unique_course_ids(site)
        course_ids(site) - sites.reject { |other| other == site }.flat_map { |other| course_ids(other) }
      end

      def sites_with_courses
        sites.count { |site| course_ids(site).any? }
      end

      def surplus
        sites.size - 1
      end

      def provider_school_surplus
        [provider_schools.size - 1, 0].max
      end
    end
  end
end
