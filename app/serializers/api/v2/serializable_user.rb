module API
  module V2
    class SerializableUser < JSONAPI::Serializable::Resource
      type "users"

      attributes :first_name, :last_name, :email, :accept_terms_date_utc, :state
    end
  end
end
