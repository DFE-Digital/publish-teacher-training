module API
  module V2
    class SerializableProviderEnrichment < JSONAPI::Serializable::Resource
      type "provider_enrichment"

      has_one :provider

      attributes  :email, :website, :address1, :address2, :address3, :address4,
                  :postcode, :region_code, :telephone, :train_with_us, :train_with_disability, :status
    end
  end
end
