# frozen_string_literal: true

module Rollover
  module Schools
    class LegacyCourseCopier
      def initialize(site_copier:)
        @site_copier = site_copier
      end

      def call(course:, new_provider:, new_course:)
        course.sites.each do |site|
          new_site = new_provider.sites.find_by(code: site.code)
          site_copier.call(new_site:, new_course:) if new_site.present?
        end
      end

    private

      attr_reader :site_copier
    end
  end
end
