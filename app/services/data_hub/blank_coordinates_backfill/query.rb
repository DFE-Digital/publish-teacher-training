# frozen_string_literal: true

module DataHub
  module BlankCoordinatesBackfill
    class Query
      attr_reader :recruitment_cycle

      def initialize(recruitment_cycle)
        @recruitment_cycle = recruitment_cycle
      end

      def call
        Log.info("Fetching records with blank coordinates for cycle year=#{recruitment_cycle.year}")
        sites_needing_backfill + gias_schools_needing_backfill
      end

      def total_count
        count = sites_relation.count + gias_schools_relation.count
        Log.info("Total records needing backfill: #{count} (Sites: #{sites_relation.count}, GIAS Schools: #{gias_schools_relation.count})")
        count
      end

    private

      def sites_relation
        @recruitment_cycle.sites.kept.not_geocoded
      end

      def gias_schools_relation
        GiasSchool.where(latitude: nil).or(GiasSchool.where(longitude: nil))
      end

      def sites_needing_backfill
        sites_relation.pluck(:id).map { |id| { type: "Site", id: } }
      end

      def gias_schools_needing_backfill
        gias_schools_relation.pluck(:id).map { |id| { type: "GiasSchool", id: } }
      end
    end
  end
end
