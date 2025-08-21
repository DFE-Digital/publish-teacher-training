module DataHub
  module Rollover
    class StudySiteCodeOrchestrator
      attr_reader :target_provider, :sites_to_copy, :used_codes

      def initialize(target_provider:, sites_to_copy:)
        @target_provider = target_provider
        @sites_to_copy = sites_to_copy
        @used_codes = Set.new(target_provider.sites.pluck(:code) + target_provider.study_sites.pluck(:code))
      end

      def call
        sites_to_copy.map do |site|
          assigned_code = generate_unique_code_for_site(site)
          { site:, code: assigned_code }
        end
      end

    private

      def generate_unique_code_for_site(site)
        code = if used_codes.include?(site.code)
                 find_next_available_code
               else
                 site.code
               end

        used_codes.add(code)
        code
      end

      def find_next_available_code
        available_desirable = Site::DESIRABLE_CODES - used_codes.to_a
        return available_desirable.first if available_desirable.any?

        available_confused = Site::EASILY_CONFUSED_CODES - used_codes.to_a
        return available_confused.first if available_confused.any?

        generate_sequential_code
      end

      def generate_sequential_code
        sequential_codes = used_codes.to_a - Site::POSSIBLE_CODES
        highest = sequential_codes.compact.max || "Z"
        highest.next
      end
    end
  end
end
