# frozen_string_literal: true

module API
  module V3
    class SerializableProvider < JSONAPI::Serializable::Resource
      include JsonapiCacheKeyHelper

      type "providers"

      attributes :provider_code, :provider_name, :provider_type,
        :longitude, :address1, :address2, :address3, :address4,
        :postcode, :latitude, :longitude, :can_sponsor_student_visa,
        :can_sponsor_skilled_worker_visa, :website, :train_with_us,
        :train_with_disability, :email, :telephone

      attribute :recruitment_cycle_year do
        @object.recruitment_cycle.year
      end
    end
  end
end
