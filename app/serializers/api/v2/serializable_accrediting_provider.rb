# This lightweight serializer is to reduce the amount of database
# hits needed to build this and reduce the amount of data sent
# over the wire that isn't used in the front-end

module API
  module V2
    class SerializableAccreditingProvider < JSONAPI::Serializable::Resource
      type 'accrediting_providers'

      attributes :provider_code, :provider_name
    end
  end
end
