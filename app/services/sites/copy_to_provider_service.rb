module Sites
  class CopyToProviderService
    def execute(site:, new_provider:)
      new_site = new_provider.sites.find_by(code: site.code)

      return nil if new_site.present?

      new_site = site.dup
      new_site.provider_id = new_provider.id
      new_site.skip_geocoding = true
      new_site.save(validate: false)
      new_provider.reload

      new_site
    end
  end
end
