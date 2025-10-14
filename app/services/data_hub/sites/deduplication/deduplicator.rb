# frozen_string_literal: true

module DataHub
  module Sites
    module Deduplication
      # Performs site deduplication for school sites, moving associations onto a
      # canonical site per duplicate group and capturing a detailed per-group outcome.
      class Deduplicator
        STATUS_PRIORITY = {
          "running" => 3,
          "new_status" => 2,
          "suspended" => 1,
          "discontinued" => 0,
          nil => -1,
        }.freeze

        PUBLISH_PRIORITY = {
          "published" => 2,
          "Y" => 2,
          "unpublished" => 1,
          "N" => 1,
          nil => 0,
        }.freeze

        # Captures the actions taken for a set of duplicate sites.
        GroupResult = Struct.new(
          :primary_site_id,
          :duplicate_site_ids,
          :sites_discarded,
          :site_status_reassignments,
          :site_status_merges,
          :site_status_removals,
          keyword_init: true,
        )

        # @param site_scope [ActiveRecord::Relation<Site>] the pool of sites to inspect.
        #   Only school sites with a URN are considered to avoid accidental deduplication.
        # @param dry_run [Boolean] whether to avoid mutating persistent data
        def initialize(site_scope:, dry_run:)
          @site_scope = site_scope.kept
          @dry_run = dry_run
          @groups = []
        end

        # Executes the deduplication for the configured scope.
        #
        # @return [Outcome] summarised deduplication actions
        def call
          duplicate_groups.each do |sites|
            groups << deduplicate_group(sites)
          end

          Outcome.new(groups:, dry_run:)
        end

      private

        attr_reader :site_scope, :dry_run, :groups

        def duplicate_groups
          grouped = Hash.new { |hash, key| hash[key] = [] }

          site_scope.find_each do |site|
            next unless site.school?
            next if site.urn.blank?

            grouped[deduplication_key_for(site)] << site
          end

          grouped.values.select { |sites| sites.size > 1 }
        end

        # Builds the deduplication key used to group sites.
        #
        # @param site [Site]
        # @return [Array<String, Integer>]
        def deduplication_key_for(site)
          [:urn, site.provider_id, site.site_type, normalize(site.urn)]
        end

        def normalize(value)
          value.to_s.strip.downcase
        end

        # Deduplicates a single group of sites that share the same key.
        #
        # @param sites [Array<Site>]
        # @return [GroupResult]
        def deduplicate_group(sites)
          primary = pick_primary_site(sites)
          duplicates = sites - [primary]

          result = GroupResult.new(
            primary_site_id: primary.id,
            duplicate_site_ids: duplicates.map(&:id),
            sites_discarded: [],
            site_status_reassignments: [],
            site_status_merges: [],
            site_status_removals: [],
          )

          duplicates.each do |duplicate|
            merge_site!(primary, duplicate, result)
          end

          result
        end

        # @param sites [Array<Site>]
        # @return [Site]
        def pick_primary_site(sites)
          sites.max_by do |site|
            [site.site_statuses.count, -site.id]
          end
        end

        # @param primary [Site]
        # @param duplicate [Site]
        # @param result [GroupResult]
        def merge_site!(primary, duplicate, result)
          ActiveRecord::Base.transaction do
            reassign_site_statuses!(primary, duplicate, result)
            discard_site!(duplicate, result)
          end
        end

        # Moves or merges site statuses from a duplicate site onto the primary.
        #
        # @param primary [Site]
        # @param duplicate [Site]
        # @param result [GroupResult]
        def reassign_site_statuses!(primary, duplicate, result)
          duplicate.site_statuses.find_each do |status|
            existing = SiteStatus.find_by(course_id: status.course_id, site_id: primary.id)

            if existing
              merge_site_status!(existing, status, result)
            else
              result.site_status_reassignments << {
                site_status_id: status.id,
                course_id: status.course_id,
              }
              status.update!(site: primary) unless dry_run
            end
          end
        end

        # When we find duplicate site statuses for the same course/site we merge
        # them, preferring the configuration with higher priority.
        #
        # @param existing [SiteStatus]
        # @param redundant [SiteStatus]
        # @param result [GroupResult]
        def merge_site_status!(existing, redundant, result)
          updates = {}

          if better_status?(redundant.status, existing.status)
            updates[:status] = redundant.status
          end

          if better_publish_flag?(redundant.publish, existing.publish)
            updates[:publish] = redundant.publish
          end

          result.site_status_merges << {
            kept_site_status_id: existing.id,
            removed_site_status_id: redundant.id,
            updated_fields: updates.keys,
          }

          existing.update!(updates) if updates.any? && !dry_run
          destroy_record(redundant) unless dry_run

          result.site_status_removals << {
            site_status_id: redundant.id,
            course_id: redundant.course_id,
          }
        end

        # Marks a duplicate site as discarded or records the intention in dry-run mode.
        #
        # @param duplicate [Site]
        # @param result [GroupResult]
        def discard_site!(duplicate, result)
          result.sites_discarded << duplicate.id
          return if dry_run

          duplicate.update_column(:discarded_via_script, true)
          duplicate.discard!
        end

        def destroy_record(record)
          record.destroy!
        end

        def better_status?(candidate, current)
          STATUS_PRIORITY.fetch(candidate, STATUS_PRIORITY[nil]) > STATUS_PRIORITY.fetch(current, STATUS_PRIORITY[nil])
        end

        def better_publish_flag?(candidate, current)
          PUBLISH_PRIORITY.fetch(candidate, PUBLISH_PRIORITY[nil]) > PUBLISH_PRIORITY.fetch(current, PUBLISH_PRIORITY[nil])
        end
      end
    end
  end
end
