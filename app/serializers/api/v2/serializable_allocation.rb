module API
  module V2
    class SerializableAllocation < JSONAPI::Serializable::Resource
      type "allocations"
      attributes :number_of_places, :request_type

      belongs_to :accredited_body
      belongs_to :provider
    end
  end
end
