module Sites
  class CopyToProviderService
    Result = Struct.new(:success?, :site, :error_message, keyword_init: true)

    def execute(site:, new_provider:, assigned_code: nil)
      new_site = build_new_site(site, new_provider, assigned_code)
      save_site(new_site)
    end

  private

    def build_new_site(site, new_provider, assigned_code)
      new_site = site.dup
      new_site.provider_id = new_provider.id
      new_site.skip_geocoding = true
      new_site.uuid = SecureRandom.uuid
      new_site.site_type = "study_site" if site.study_site?
      new_site.code = assigned_code if assigned_code
      new_site
    end

    def save_site(new_site)
      new_site.save!(validate: false)
      success_result(new_site)
    rescue StandardError => e
      error_result(e.message)
    end

    def success_result(site)
      Result.new(success?: true, site:, error_message: nil)
    end

    def error_result(error_message)
      Result.new(success?: false, site: nil, error_message:)
    end
  end
end
