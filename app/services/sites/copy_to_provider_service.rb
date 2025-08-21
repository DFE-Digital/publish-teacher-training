# frozen_string_literal: true

module Sites
  class CopyToProviderService
    Result = Struct.new(:success?, :site, :error_message, keyword_init: true)

    DUPLICATE_SITE_ERROR = "Site code already exists on provider"

    def execute(site:, new_provider:)
      return duplicate_error if site_already_exists?(site, new_provider)

      create_site(site, new_provider)
    end

  private

    def site_already_exists?(site, new_provider)
      new_provider.sites.exists?(code: site.code) || new_provider.study_sites.exists?(code: site.code)
    end

    def duplicate_error
      Result.new(success?: false, site: nil, error_message: DUPLICATE_SITE_ERROR)
    end

    def create_site(site, new_provider)
      new_site = build_new_site(site, new_provider)

      save_site(new_site, new_provider)
    rescue StandardError => e
      Result.new(success?: false, site: nil, error_message: e.message)
    end

    def build_new_site(site, new_provider)
      new_site = site.dup
      new_site.provider_id = new_provider.id
      new_site.skip_geocoding = true
      new_site.uuid = SecureRandom.uuid
      new_site.site_type = "study_site" if site.study_site?
      new_site
    end

    def save_site(new_site, new_provider)
      new_site.save!(validate: false)
      new_provider.reload

      Result.new(success?: true, site: new_site, error_message: nil)
    end
  end
end
