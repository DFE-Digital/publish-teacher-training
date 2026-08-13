# frozen_string_literal: true

module DataHub
  module DuplicateSchools
    # Finds the (provider, urn) pairs held by more than one live school site and
    # returns them as classified groups. Reads only.
    #
    # Deliberately excluded from the grouping key: `code`. The query this
    # replaces filtered `code <> '-'`, which hid the largest shape - a
    # provider's main site colliding with the same school added again as a
    # placement school.
    class Classifier
      def initialize(years:)
        @years = Array(years).map(&:to_s)
      end

      # @return [Array<Group>]
      def call
        keys = duplicate_keys
        return [] if keys.empty?

        sites = sites_for(keys).group_by { |site| [site.provider_id, site.urn] }
        gias_schools = GiasSchool.where(urn: keys.map(&:last).uniq).index_by(&:urn)
        provider_schools = provider_schools_for(keys.map(&:first).uniq, gias_schools.values)

        keys.filter_map do |key|
          group_sites = sites[key]
          next if group_sites.blank?

          provider = group_sites.first.provider
          gias_school = gias_schools[key.last]

          Group.new(
            year: provider.recruitment_cycle.year,
            provider:,
            urn: key.last,
            sites: group_sites.sort_by(&:id),
            gias_school:,
            provider_schools: provider_schools[[provider.id, gias_school&.id]].to_a,
          )
        end
      end

    private

      attr_reader :years

      def duplicate_keys
        Site.kept
            .school
            .where.not(urn: [nil, ""])
            .joins(provider: :recruitment_cycle)
            .where(provider: { discarded_at: nil }, recruitment_cycle: { year: years })
            .group(:provider_id, :urn)
            .having("COUNT(*) > 1")
            .pluck(:provider_id, :urn)
      end

      def sites_for(keys)
        Site.kept
            .school
            .where(provider_id: keys.map(&:first).uniq, urn: keys.map(&:last).uniq)
            .includes(:site_statuses, provider: :recruitment_cycle)
            .select { |site| keys.include?([site.provider_id, site.urn]) }
      end

      def provider_schools_for(provider_ids, gias_schools)
        Provider::School
          .where(provider_id: provider_ids, gias_school_id: gias_schools.map(&:id))
          .includes(:course_schools)
          .group_by { |provider_school| [provider_school.provider_id, provider_school.gias_school_id] }
      end
    end
  end
end
