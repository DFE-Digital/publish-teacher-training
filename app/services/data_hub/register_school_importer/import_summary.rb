module DataHub
  module RegisterSchoolImporter
    class ImportSummary
      class ProviderSummary
        include ActiveModel::Model
        attr_accessor :provider_code,
                      :provider_not_found,
                      :ignored_schools,
                      :schools_added,
                      :school_errors,
                      :school_errors_urns,
                      :school_errors_count
      end

      IGNORE_REASONS = {
        not_found_in_gias: "Not found in GIAS",
        school_already_exists: "Already exists for provider",
      }.freeze

      def initialize
        @provider_summaries = Hash.new do |provider_summaries, provider_code|
          provider_summaries[provider_code] = ProviderSummary.new(
            provider_code:,
            provider_not_found: [],
            ignored_schools: [],
            schools_added: [],
            school_errors: [],
            school_errors_urns: [],
            school_errors_count: 0,
          )
        end
      end

      def mark_provider_not_found(provider_code, row)
        @provider_summaries[provider_code].provider_not_found << { row: }
      end

      def mark_ignored_schools(provider_code, urns_with_reasons)
        @provider_summaries[provider_code].ignored_schools.concat(urns_with_reasons)
      end

      def mark_schools_added(provider_code, urns)
        @provider_summaries[provider_code].schools_added.concat(urns)
      end

      def mark_school_errors(provider_code, school_errors)
        school_errors.each do |school_error|
          @provider_summaries[provider_code].school_errors << school_error
          @provider_summaries[provider_code].school_errors_urns << school_error[:urn]
          @provider_summaries[provider_code].school_errors_count += 1
        end
      end

      def provider_summaries
        @provider_summaries.values
      end

      def meta
        schools_added_count = 0
        providers_not_found_codes = Set.new
        schools_not_found_in_gias_urns = []
        schools_already_exists_count = 0
        school_errors_count = 0
        school_errors_urns = []

        provider_summaries.each do |group|
          schools_added_count += group.schools_added.size

          providers_not_found_codes << group.provider_code if group.provider_not_found.any?

          group.ignored_schools.each do |ignored|
            if ignored[:reason] == IGNORE_REASONS[:not_found_in_gias]
              schools_not_found_in_gias_urns << ignored[:urn]
            elsif ignored[:reason] == IGNORE_REASONS[:school_already_exists]
              schools_already_exists_count += 1
            end
          end

          school_errors_count += group.school_errors_count
          school_errors_urns.concat(group.school_errors_urns)
        end

        {
          schools_added_count: schools_added_count,
          providers_not_found_count: providers_not_found_codes.size,
          providers_not_found_codes: providers_not_found_codes.to_a,
          schools_not_found_in_gias_count: schools_not_found_in_gias_urns.size,
          schools_not_found_in_gias_urns: schools_not_found_in_gias_urns,
          schools_already_exists_count: schools_already_exists_count,
          school_errors_count: school_errors_count,
          school_errors_urns: school_errors_urns,
        }
      end

      def full_summary
        {
          meta:,
          provider_summaries: @provider_summaries,
        }
      end
    end
  end
end
