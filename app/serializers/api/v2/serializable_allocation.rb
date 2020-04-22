module API
  module V2
    class SerializableAllocation < JSONAPI::Serializable::Resource
      type "allocations"
      attributes :number_of_places

      belongs_to :accredited_body
      belongs_to :provider
    end
  end
end
