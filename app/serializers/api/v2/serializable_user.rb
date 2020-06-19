module API
  module V2
    class SerializableUser < JSONAPI::Serializable::Resource
      type "users"
      has_many :organisations

      attributes :first_name, :last_name, :email, :accept_terms_date_utc, :state, :admin, :sign_in_user_id

      attribute :associated_with_accredited_body do
        @object.associated_with_accredited_body?
      end

      attribute :notifications_configured do
        @object.notifications_configured?
      end
    end
  end
end
