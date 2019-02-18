module API
  module V2
    class CourseSerializable < JSONAPI::Serializable::Resource
      type 'courses'

      attributes :findable?, :applications_being_accepted_now?, :has_vacancies?,
                 :course_code, :name, :study_mode, :profpost_flag

      attribute :start_date do
        @object.start_date&.iso8601
      end

      has_one :provider
      has_one :accrediting_provider
    end
  end
end
