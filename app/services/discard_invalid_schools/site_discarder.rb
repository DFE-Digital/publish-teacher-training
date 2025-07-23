module DiscardInvalidSchools
  class SiteDiscarder
    Result = Struct.new(:site_id, :urn, :reason, keyword_init: true)

    def initialize(site:)
      @site = site
    end

    def call
      site.transaction do
        site.update_columns(discarded_via_script: true)
        site.discard
      end

      Result.new(
        site_id: site.id,
        urn: site.urn,
        reason: discard_reason,
      )
    end

  private

    attr_reader :site

    def discard_reason
      site.urn.blank? ? :no_urn : :invalid_urn
    end
  end
end
