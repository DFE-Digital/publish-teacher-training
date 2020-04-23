module API
  module V2
    class DeserializableAllocation < JSONAPI::Deserializable::Resource
      attributes :provider_id,
                 :number_of_places
    end
  end
end
