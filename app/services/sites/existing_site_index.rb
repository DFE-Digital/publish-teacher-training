# frozen_string_literal: true

module Sites
  # Answers "does the target provider already have this study site?" for the
  # rollover, which saves with `validate: false` and so bypasses the uniqueness
  # rules Site would otherwise enforce.
  #
  # Study sites are identified by location name, which Site validates as unique
  # per provider and site type, and by URN when they have one — the two checks
  # Publish::StudySiteForm makes before letting anyone add a study site. Code is
  # deliberately absent here: StudySiteCodeOrchestrator reassigns study site
  # codes as it copies them, so a code is not stable across runs.
  #
  # The index is a snapshot of what the target provider had before the copy
  # started, and is deliberately never updated with the sites being copied.
  # Courses::CopyToProviderService resolves a source site to its copy by code,
  # so folding fresh copies in would collapse two same-named source sites onto
  # one copy and silently drop the second one's course placement.
  class ExistingSiteIndex
    def self.for(provider:)
      sites = Site.kept
                  .where(provider_id: provider.id, site_type: :study_site)
                  .select(:id, :code, :urn, :location_name, :site_type)

      new(sites.flat_map { keys_for(it) })
    end

    def self.keys_for(site)
      return [] unless site.study_site?

      [
        [:study_site, :location_name, normalize(site.location_name)],
        ([:study_site, :urn, normalize(site.urn)] if site.urn.present?),
      ].compact
    end

    def self.normalize(value)
      value.to_s.strip.downcase
    end

    def initialize(keys)
      @keys = keys.to_set
    end

    def already_copied?(site)
      self.class.keys_for(site).any? { keys.include?(it) }
    end

  private

    attr_reader :keys
  end
end
