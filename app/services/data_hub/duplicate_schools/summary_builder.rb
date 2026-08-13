# frozen_string_literal: true

module DataHub
  module DuplicateSchools
    # Builds a short and full summary for a classification run ready for
    # persistence. The run changes nothing, so this is its whole output: the
    # counts a merge policy gets chosen from, and the evidence behind them.
    class SummaryBuilder
      def initialize(groups:, years:)
        @groups = groups
        @years = years
      end

      # @return [Hash] the counts, and the same counts split by kind and flag
      def short_summary
        {
          years:,
          groups_processed: groups.size,
          surplus_sites: groups.sum(&:surplus),
          surplus_provider_schools: groups.sum(&:provider_school_surplus),
          kinds: kind_tally,
          flags: flag_tally,
        }
      end

      # @return [Hash] every group, so the report can be rebuilt without running
      #   against production again
      def full_summary
        { duplicate_groups: groups.map { |group| describe_group(group) } }
      end

    private

      attr_reader :groups, :years

      def kind_tally
        groups.group_by { |group| group.kind.label }.map do |label, found|
          {
            kind: label,
            groups: found.size,
            surplus_sites: found.sum(&:surplus),
            surplus_provider_schools: found.sum(&:provider_school_surplus),
          }
        end
      end

      def flag_tally
        groups
          .flat_map { |group| group.kind.raised_flags }
          .tally
          .map { |flag, count| { flag: flag.to_s, groups: count } }
      end

      def describe_group(group)
        {
          year: group.year,
          provider_id: group.provider.id,
          provider_code: group.provider.provider_code,
          provider_name: group.provider.provider_name,
          urn: group.urn,
          kind: group.kind.label,
          flags: group.kind.raised_flags.map(&:to_s),
          gias_school_id: group.gias_school&.id,
          gias_name: group.gias_school&.name,
          gias_status: group.gias_school&.status_code,
          sites: group.sites.map { |site| describe_site(group, site) },
          provider_schools: group.provider_schools.map { |row| describe_provider_school(row) },
        }
      end

      def describe_site(group, site)
        {
          id: site.id,
          code: site.code,
          location_name: site.location_name,
          created_at: site.created_at.iso8601,
          added_via: site.added_via,
          courses: group.course_ids(site).size,
          unique_courses: group.unique_course_ids(site).size,
          uuid: site.uuid,
        }
      end

      def describe_provider_school(provider_school)
        {
          id: provider_school.id,
          site_code: provider_school.site_code,
          course_schools: provider_school.course_schools.size,
        }
      end
    end
  end
end
