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
