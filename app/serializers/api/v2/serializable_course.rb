module API
  module V2
    class SerializableCourse < JSONAPI::Serializable::Resource
      type 'courses'

      attributes :findable?, :open_for_applications?, :has_vacancies?,
                 :course_code, :name, :study_mode, :qualifications, :description,
                 :content_status, :ucas_status, :funding

      attribute :start_date do
        @object.start_date&.iso8601
      end

      belongs_to :provider
      belongs_to :accrediting_provider

      has_many :site_statuses
      has_many :subjects
    end
  end
end
