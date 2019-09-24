module API
  module V2
    class SerializableProviderSuggestion < JSONAPI::Serializable::Resource
      type "provider"

      attributes :provider_name, :provider_code
    end
  end
end
