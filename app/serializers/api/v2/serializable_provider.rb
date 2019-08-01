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

      attributes :provider_code, :provider_name, :accredited_body?, :can_add_more_sites?, :content_status


      attribute :address1 do
        @object.external_contact_info['address1']
      end

      attribute :address2 do
        @object.external_contact_info['address2']
      end

      attribute :address3 do
        @object.external_contact_info['address3']
      end

      attribute :address4 do
        @object.external_contact_info['address4']
      end

      attribute :postcode do
        @object.external_contact_info['postcode']
      end

      attribute :region_code do
        @object.external_contact_info['region_code']
      end

      attribute :telephone do
        @object.external_contact_info['telephone']
      end

      attribute :email do
        @object.external_contact_info['email']
      end

      attribute :website do
        @object.external_contact_info['website']
      end

      attribute :recruitment_cycle_year do
        @object.recruitment_cycle.year
      end

      attribute :last_published_at do
        @object.last_published_at&.iso8601
      end

      enrichment_attribute :train_with_us
      enrichment_attribute :train_with_disability

      has_many :sites

      meta do
        {
          accredited_bodies:
            @object.accrediting_providers.map do |ap|
              accrediting_provider_entry = @object.latest_enrichment.accrediting_provider_enrichments.find do |ape|
                ape['UcasProviderCode'] == ap.provider_code
              end

              {
                provider_name: ap.provider_name,
                provider_code: ap.provider_code,
                description: accrediting_provider_entry['Description']
              }
            end
        }
      end

      has_many :accrediting_provider_enrichments
      has_one :latest_enrichment, key: :ProviderEnrichment, serializer: API::V2::SerializableProviderEnrichment

      has_many :courses do
        meta do
          { count: @object.courses_count }
        end
      end
    end
  end
end
