module API
  module V2
    class SerializableProvider < JSONAPI::Serializable::Resource
      type 'providers'

      attribute :institution_code do
        @object.provider_code
      end

      attribute :institution_name do
        @object.provider_name
      end
    end
  end
end
