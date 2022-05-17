module API
  module V2
    class SerializableAllocation < JSONAPI::Serializable::Resource
      type "allocations"

      attributes :confirmed_number_of_places, :number_of_places, :request_type

      belongs_to :accredited_body
      belongs_to :provider
      has_one :allocation_uplift
    end
  end
end
