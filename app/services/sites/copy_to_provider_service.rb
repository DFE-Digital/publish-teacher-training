# frozen_string_literal: true

module Sites
  class CopyToProviderService
    def execute(site:, new_provider:)
      new_site = new_provider.sites.find_by(code: site.code) || new_provider.study_sites.find_by(code: site.code)

      return if new_site.present?

      new_site = site.dup
      new_site.provider_id = new_provider.id
      new_site.skip_geocoding = true
      new_site.uuid = SecureRandom.uuid
      new_site.site_type = "study_site" if site.study_site?
      new_site.save!(validate: false)
      new_provider.reload

      new_site
    end
  end
end
