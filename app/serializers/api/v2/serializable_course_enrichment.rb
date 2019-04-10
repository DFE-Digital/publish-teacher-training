module API
  module V2
    class SerializableCourseEnrichment < JSONAPI::Serializable::Resource
      type 'course_enrichments'

      attributes :json_data, :status, :has_been_published_before?

      belongs_to :course
    end
  end
end
