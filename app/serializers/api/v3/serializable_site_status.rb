module API
  module V3
    class SerializableSiteStatus < JSONAPI::Serializable::Resource
      include JsonapiCacheKeyHelper

      type "site_statuses"
      attributes :vac_status, :publish, :status, :has_vacancies?

      has_one :site
    end
  end
end
