module API
  module V3
    class SerializableProvider < JSONAPI::Serializable::Resource
      type "providers"

      attributes :provider_code, :provider_name,
                 :provider_type, :address1, :address2,
                 :address3, :address4, :postcode, :region_code,
                 :email, :website, :telephone,
                 :train_with_us, :train_with_disability,
                 :accredited_bodies, :accredited_body?,
                 :latitude, :longitude

      attribute :recruitment_cycle_year do
        @object.recruitment_cycle.year
      end

      has_many :sites

      has_many :courses do
        meta do
          { count: @object.courses_count }
        end
      end
    end
  end
end
