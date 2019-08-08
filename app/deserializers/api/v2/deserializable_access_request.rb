module API
  module V2
    class DeserializableAccessRequest < JSONAPI::Deserializable::Resource
      attributes :first_name,
                 :last_name,
                 :email_address,
                 :organisation,
                 :reason,
                 :requester_email
    end
  end
end
