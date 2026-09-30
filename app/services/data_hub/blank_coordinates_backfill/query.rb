# frozen_string_literal: true

module DataHub
  module BlankCoordinatesBackfill
    class Query
      attr_reader :recruitment_cycle

      def initialize(recruitment_cycle)
        @recruitment_cycle = recruitment_cycle
      end

      def call
        each_batch(batch_size: 1_000).to_a.flatten(1)
      end

      def each_batch(batch_size:)
        return enum_for(__method__, batch_size:) unless block_given?

        Log.info("Fetching records with blank coordinates for cycle year=#{recruitment_cycle.year}")
        batch = []

        each_record(batch_size:) do |record|
          batch << record
          next unless batch.size == batch_size

          yield batch
          batch = []
        end

        yield batch if batch.any?
      end

      def total_count
        sites_count = sites_relation.count
        schools_count = gias_schools_relation.count
        count = sites_count + schools_count
        Log.info("Total records needing backfill: #{count} (Sites: #{sites_count}, GIAS Schools: #{schools_count})")
        count
      end

    private

      def sites_relation
        @recruitment_cycle.sites.kept.not_geocoded
      end

      def gias_schools_relation
        GiasSchool.where(latitude: nil).or(GiasSchool.where(longitude: nil))
      end

      def each_record(batch_size:)
        sites_relation.select(:id).find_each(batch_size:) do |site|
          yield({ type: "Site", id: site.id })
        end

        gias_schools_relation.select(:id).find_each(batch_size:) do |school|
          yield({ type: "GiasSchool", id: school.id })
        end
      end
    end
  end
end
