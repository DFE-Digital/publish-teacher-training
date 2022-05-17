module API
  module V2
    class SerializableInterruptPageAcknowledgement < JSONAPI::Serializable::Resource
      type "interrupt_page_acknowledgements"
      has_one :user
      has_one :recruitment_cycle

      attributes :page, :created_at, :updated_at
    end
  end
end
