# frozen_string_literal: true

module Sites
  # Answers "does the target provider already have this site?" for the rollover
  # copiers, which save with `validate: false` and so bypass the uniqueness rules
  # Site would otherwise enforce.
  #
  # Identity follows those same rules:
  #
  # * school sites are identified by URN and code together. URN alone is not
  #   identity: a provider can hold one URN twice, on a main site and on an
  #   ordinary site, since main sites are matched to GIAS by postcode. A copy
  #   keeps its source's code, so the pair is stable across runs, and the URN-less
  #   sites the presence validation exempts simply key on their code alone
  # * study sites are identified by location name, which Site validates as unique
  #   per provider and site type, and by URN when they have one — the two checks
  #   Publish::StudySiteForm makes before letting anyone add a study site. Code is
  #   deliberately absent here: StudySiteCodeOrchestrator reassigns study site
  #   codes as it copies them, so a code is not stable across runs
  #
  # The index is a snapshot of what the target provider had before the copy
  # started, and is deliberately never updated with the sites being copied.
  # Rollover::Schools::LegacyCourseCopier and Courses::CopyToProviderService both
  # resolve a source site to its copy by code, so folding fresh copies in would
  # collapse two same-named source sites onto one copy and silently drop the
  # second one's course placement.
  class ExistingSiteIndex
    def self.for(provider:, site_type:)
      sites = Site.kept
                  .where(provider_id: provider.id, site_type:)
                  .select(:id, :code, :urn, :location_name, :site_type)

      new(sites.flat_map { keys_for(it) })
    end

    def self.keys_for(site)
      if site.study_site?
        [
          [:study_site, :location_name, normalize(site.location_name)],
          ([:study_site, :urn, normalize(site.urn)] if site.urn.present?),
        ].compact
      else
        [[:school, normalize(site.urn), site.code]]
      end
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
