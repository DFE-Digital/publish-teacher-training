module API
  module V2
    class SerializableUser < JSONAPI::Serializable::Resource
      type 'users'

      attributes :first_name, :last_name, :email, :accept_terms_date_utc

      attribute :state do
        @object.state
      end
    end
  end
end
