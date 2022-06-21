module API
  module Public
    module V1
      class SerializableLocationStatus < JSONAPI::Serializable::Resource
        extend JSONAPI::Serializable::Resource::ConditionalFields

        type "location_statuses"

        attributes :publish,
          :status

        attribute :vacancy_status do
          @object.vac_status
        end

        attribute :has_vacancies do
          @object.has_vacancies?
        end
      end
    end
  end
end
