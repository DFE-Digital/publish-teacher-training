module API
  module V2
    class SerializableCourse < JSONAPI::Serializable::Resource
      type 'courses'

      attributes :findable?, :open_for_applications?, :has_vacancies?,
                 :course_code, :name, :study_mode, :qualifications, :description,
                 :content_status, :ucas_status

      attribute :start_date do
        @object.start_date&.iso8601
      end

      has_one :provider
      has_one :accrediting_provider

      has_many :site_statuses
    end
  end
end
