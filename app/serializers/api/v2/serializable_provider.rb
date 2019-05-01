module API
  module V2
    class SerializableProvider < JSONAPI::Serializable::Resource
      class << self
        def enrichment_attribute(name, enrichment_name = name)
          attribute name do
            @object.enrichments.last&.__send__(enrichment_name)
          end
        end
      end

      type 'providers'

      attributes :provider_code, :provider_name, :accredited_body?, :can_add_more_sites?

      attribute :website do
        if @object.enrichments.last&.__send__(:website).present?
          @object.enrichments.last&.__send__(:website)
        else
          @object.url
        end
      end

      attribute :email do
        if @object.enrichments.last&.__send__(:email).present?
          @object.enrichments.last&.__send__(:email)
        else
          @object.email
        end
      end

      attribute :telephone do
        if @object.enrichments.last&.__send__(:telephone).present?
          @object.enrichments.last&.__send__(:telephone)
        else
          @object.telephone
        end
      end

      attribute :address1 do
        if @object.enrichments.last&.__send__(:address1).present?
          @object.enrichments.last&.__send__(:address1)
        else
          @object.address1
        end
      end

      attribute :address2 do
        if @object.enrichments.last&.__send__(:address2).present?
          @object.enrichments.last&.__send__(:address2)
        else
          @object.address2
        end
      end

      attribute :address3 do
        if @object.enrichments.last&.__send__(:address3).present?
          @object.enrichments.last&.__send__(:address3)
        else
          @object.address3
        end
      end

      attribute :address4 do
        if @object.enrichments.last&.__send__(:address4).present?
          @object.enrichments.last&.__send__(:address4)
        else
          @object.address4
        end
      end

      attribute :postcode do
        if @object.enrichments.last&.__send__(:postcode).present?
          @object.enrichments.last&.__send__(:postcode)
        else
          @object.postcode
        end
      end

      enrichment_attribute :train_with_us
      enrichment_attribute :train_with_disability

      has_many :sites

      has_many :courses do
        meta do
          { count: @object.courses.size }
        end
      end
    end
  end
end
