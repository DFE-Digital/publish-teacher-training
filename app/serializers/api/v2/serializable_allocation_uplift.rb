module API
  module V2
    class SerializableAllocationUplift < JSONAPI::Serializable::Resource
      type "allocation_uplift"

      attributes :uplifts

      belongs_to :allocation
    end
  end
end
