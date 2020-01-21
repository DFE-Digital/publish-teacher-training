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
    recruitment_cycle_serializer: API::V2::SerializableRecruitmentCycle,
    v3_subject_area_serializer: API::V3::SerializableSubjectArea
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

    @v3_subject_area_serializer = v3_subject_area_serializer
  end

  def execute
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
      v3: {
        SubjectArea: @v3_subject_area_serializer,
        #this is ok until the serializers for subjects need to diverge from V2
        Subject: @subject_serializer,
        PrimarySubject: @primary_subject_serializer,
        SecondarySubject: @secondary_subject_serializer,
        ModernLanguagesSubject: @modern_languages_subject_serializer,
        FurtherEducationSubject: @further_education_subject_serializer,
      },
    }
  end
end
