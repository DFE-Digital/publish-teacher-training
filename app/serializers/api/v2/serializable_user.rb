module API
  module V2
    class SerializableUser < JSONAPI::Serializable::Resource
      type "users"
      has_many :organisations

      attributes :first_name, :last_name, :email, :accept_terms_date_utc, :state, :admin
    end
  end
end
