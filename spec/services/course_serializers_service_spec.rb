describe CourseSerializersService do
  let(:course_serializer_spy) { spy }
  let(:subject_serializer_spy) { spy }
  let(:primary_subject_serializer_spy) { spy }
  let(:secondary_subject_serializer_spy) { spy }
  let(:modern_languages_subject_serializer_spy) { spy }
  let(:further_education_subject_serializer_spy) { spy }
  let(:site_status_serializer_spy) { spy }
  let(:site_serializer_spy) { spy }
  let(:provider_serializer_spy) { spy }
  let(:provider_enrichment_serializer_spy) { spy }
  let(:recruitment_cycle_serializer_spy) { spy }

  let(:course) { spy("course", present?: true) }

  let(:service) do
    described_class.new
  end

  let(:default_class_serializers) do
    {
      Course: API::V2::SerializableCourse,
      Subject: API::V2::SerializableSubject,
      PrimarySubject: API::V2::SerializableSubject,
      SecondarySubject: API::V2::SerializableSubject,
      ModernLanguagesSubject: API::V2::SerializableSubject,
      FurtherEducationSubject: API::V2::SerializableSubject,
      SiteStatus: API::V2::SerializableSiteStatus,
      Site: API::V2::SerializableSite,
      Provider: API::V2::SerializableProvider,
      ProviderEnrichment: API::V2::SerializableProviderEnrichment,
      RecruitmentCycle: API::V2::SerializableRecruitmentCycle,
    }
  end

  let(:class_serializers) do
    {
      Course: course_serializer_spy,
      Subject: subject_serializer_spy,
      PrimarySubject: primary_subject_serializer_spy,
      SecondarySubject: secondary_subject_serializer_spy,
      ModernLanguagesSubject: modern_languages_subject_serializer_spy,
      FurtherEducationSubject: further_education_subject_serializer_spy,
      SiteStatus: site_status_serializer_spy,
      Site: site_serializer_spy,
      Provider: provider_serializer_spy,
      ProviderEnrichment: provider_enrichment_serializer_spy,
      RecruitmentCycle: recruitment_cycle_serializer_spy,
    }
  end

  describe "#execute" do
    let(:course_jsonapi) { spy("course JSONAPI") }
    let(:renderer) { spy(render: course_jsonapi) }

    it "returns the default class serializers" do
      expect(service.execute).to eq(default_class_serializers)
    end
  end
end
