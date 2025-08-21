module DataHub
  module Rollover
    class StudySiteCodeOrchestrator
      attr_reader :target_provider, :sites_to_copy, :existing_codes

      def initialize(target_provider:, sites_to_copy:)
        @target_provider = target_provider
        @sites_to_copy   = sites_to_copy
        @existing_codes  = Set.new(
          target_provider.sites.pluck(:code) +
          target_provider.study_sites.pluck(:code),
        )
      end

      def call
        return handle_unique_study_site_codes if no_source_duplicates?

        handle_duplicated_study_site_codes
      end

    private

      def no_source_duplicates?
        codes = sites_to_copy.map(&:code)
        codes.size == codes.uniq.size
      end

      # When all study site codes are unique: return original codes
      def handle_unique_study_site_codes
        sites_to_copy.map { |site| { site:, code: site.code } }
      end

      # When source contains duplicate codes: reserve originals and generate new ones
      def handle_duplicated_study_site_codes
        used = existing_codes.dup

        sites_to_copy.group_by(&:code).flat_map do |original_code, group|
          group.each_with_index.map do |site, index|
            code = if index.zero?
                     reserve_or_fallback(original_code, used)
                   else
                     generate_new_code(used)
                   end

            { site:, code: }
          end
        end
      end

      def reserve_or_fallback(code, used)
        if used.include?(code)
          generate_new_code(used)
        else
          used.add(code)
          code
        end
      end

      def generate_new_code(used)
        available_desirable = Site::DESIRABLE_CODES - used.to_a
        code = available_desirable.first ||
          (Site::EASILY_CONFUSED_CODES - used.to_a).first

        unless code
          seq_source = used.to_a - Site::POSSIBLE_CODES
          highest    = seq_source.compact.max || "Z"
          code       = highest.next
        end

        used.add(code)
        code
      end
    end
  end
end
