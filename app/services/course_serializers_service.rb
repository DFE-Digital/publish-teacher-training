class CourseSerializersService
  def initialize(
    course_serializer: API::V2::SerializableCourse,
    subject_serializer: API::V2::SerializableSubject,
    primary_subject_serializer: API::V2::SerializableSubject,
    secondary_subject_serializer: API::V2::SerializableSubject,
    modern_languages_subject_serializer: API::V2::SerializableSubject,
    further_education_subject_serializer: API::V2::SerializableSubject,
    site_status_serializer: API::V2::SerializableSiteStatus,
    site_serializer: API::V2::SerializableSite,
    provider_serializer: API::V2::SerializableProvider,
    provider_enrichment_serializer: API::V2::SerializableProviderEnrichment,
    recruitment_cycle_serializer: API::V2::SerializableRecruitmentCycle
  )
    @course_serializer = course_serializer
    @subject_serializer = subject_serializer
    @primary_subject_serializer = primary_subject_serializer
    @secondary_subject_serializer = secondary_subject_serializer
    @modern_languages_subject_serializer = modern_languages_subject_serializer
    @further_education_subject_serializer = further_education_subject_serializer
    @site_serializer = site_serializer
    @site_status_serializer = site_status_serializer
    @provider_serializer = provider_serializer
    @provider_enrichment_serializer = provider_enrichment_serializer
    @recruitment_cycle_serializer = recruitment_cycle_serializer
  end

  # Convenience method to serialize an object.
  #
  # This method also provides backwards compatibility to return a set of class
  # names and their serializers, as this was how this service was originally
  # conceived.
  def execute(object = nil, opts = {})
    if object.present?
      renderer.render(object, class: serialization_classes, **opts)
    else
      serialization_classes
    end
  end

private

  def renderer
    JSONAPI::Serializable::Renderer.new
  end

  def serialization_classes
    {
      Course: @course_serializer,
      Subject: @subject_serializer,
      PrimarySubject: @primary_subject_serializer,
      SecondarySubject: @secondary_subject_serializer,
      ModernLanguagesSubject: @modern_languages_subject_serializer,
      FurtherEducationSubject: @further_education_subject_serializer,
      SiteStatus: @site_status_serializer,
      Site: @site_serializer,
      Provider: @provider_serializer,
      ProviderEnrichment: @provider_enrichment_serializer,
      RecruitmentCycle: @recruitment_cycle_serializer,
    }
  end
end
