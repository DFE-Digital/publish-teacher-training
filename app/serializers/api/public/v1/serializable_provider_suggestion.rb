module API
  module Public
    module V1
      class SerializableProviderSuggestion < JSONAPI::Serializable::Resource
        type "provider_suggestions"

        attribute :code do
          @object.provider_code
        end

        attribute :name do
          @object.provider_name
        end
      end
    end
  end
end
