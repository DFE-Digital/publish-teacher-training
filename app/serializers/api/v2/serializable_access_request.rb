module API
  module V2
    class SerializableAccessRequest < JSONAPI::Serializable::Resource
      type 'access_request'
      belongs_to :requester, class_name: 'User'

      attributes :email_address, :first_name, :last_name, :organisation,
                 :reason, :requester_id, :status, :requester_email


      attribute :request_date_utc do
        Time.now.utc.iso8601
      end
    end
  end
end
