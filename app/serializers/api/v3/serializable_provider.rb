module API
  module V3
    class SerializableProvider < JSONAPI::Serializable::Resource
      type "providers"

      attributes :provider_code, :provider_name, :provider_type,
                 :latitude, :longitude

      attribute :recruitment_cycle_year do
        @object.recruitment_cycle.year
      end
    end
  end
end
