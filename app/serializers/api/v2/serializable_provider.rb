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

      has_many :sites

      has_many :courses do
        meta do
          { count: @object.courses.size }
        end
      end
    end
  end
end
