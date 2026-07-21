# frozen_string_literal: true

module Rollover
  module Schools
    class LegacyCourseCopier
      def initialize(site_copier:)
        @site_copier = site_copier
      end

      def call(course:, new_provider:, new_course:)
        lookup = new_provider_sites(new_provider)

        course.sites.each do |site|
          new_site = lookup[site.code]
          site_copier.call(new_site:, new_course:) if new_site.present?
        end
      end

    private

      attr_reader :site_copier

      # Every site belonging to the new provider is created before any course is
      # copied, so load them once per provider rather than once per course.
      def new_provider_sites(new_provider)
        @new_provider_sites ||= {}
        @new_provider_sites[new_provider.id] ||= new_provider.sites.index_by(&:code)
      end
    end
  end
end
