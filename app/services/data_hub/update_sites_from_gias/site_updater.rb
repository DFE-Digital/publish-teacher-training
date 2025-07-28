module DataHub
  module UpdateSitesFromGias
    class SiteUpdater
      FIELDS = {
        location_name: :name,
        address1: :address1,
        address2: :address2,
        address3: :address3,
        town: :town,
        address4: :county,
        postcode: :postcode,
        latitude: :latitude,
        longitude: :longitude,
      }.freeze

      Result = Struct.new(:site_id, :changes, keyword_init: true)

      def initialize(site:, gias_school:)
        @site = site
        @gias_school = gias_school
      end

      def call
        differences = find_field_differences
        return Result.new(site_id: site.id, changes: {}) if differences.empty?

        site.transaction do
          site.skip_geocoding = true
          site.update_columns(differences.transform_values { |v| v[:after] })
        end

        Result.new(site_id: site.id, changes: differences)
      end

    private

      attr_reader :site, :gias_school

      def find_field_differences
        FIELDS.each_with_object({}) do |(site_field, gias_field), diff_hash|
          site_value = site.send(site_field)
          gias_value = gias_school[gias_field]
          if fields_differ?(site_field, site_value, gias_value)
            diff_hash[site_field] = { before: site_value, after: gias_value }
          end
        end
      end

      def fields_differ?(field, site_value, gias_value)
        case field
        when :latitude, :longitude
          floats_significantly_different?(site_value, gias_value)
        when :postcode
          normalize_postcode(site_value) != normalize_postcode(gias_value)
        else
          normalize_string(site_value) != normalize_string(gias_value)
        end
      end

      def floats_significantly_different?(site_value, gias_value, epsilon = 0.00001)
        (site_value.to_f - gias_value.to_f).abs > epsilon
      end

      def normalize_string(value)
        value.to_s.downcase.strip.presence
      end

      def normalize_postcode(value)
        value.to_s.downcase.strip.delete(" ").presence
      end
    end
  end
end
