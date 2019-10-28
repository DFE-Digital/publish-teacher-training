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

    before do
      allow(JSONAPI::Serializable::Renderer)
        .to receive(:new).and_return(renderer)
    end

    it "serializes a course object" do
      expect(service.execute(course)).to eq(course_jsonapi)
      expect(renderer).to have_received(:render)
                            .with(course, class: default_class_serializers)
    end

    it "returns the default class serializers" do
      expect(service.execute).to eq(default_class_serializers)
    end

    context "when specifying class serializers" do
      let(:service) do
        described_class.new(
          course_serializer: course_serializer_spy,
          subject_serializer: subject_serializer_spy,
          primary_subject_serializer: primary_subject_serializer_spy,
          secondary_subject_serializer: secondary_subject_serializer_spy,
          modern_languages_subject_serializer: modern_languages_subject_serializer_spy,
          further_education_subject_serializer: further_education_subject_serializer_spy,
          site_status_serializer: site_status_serializer_spy,
          site_serializer: site_serializer_spy,
          provider_serializer: provider_serializer_spy,
          provider_enrichment_serializer: provider_enrichment_serializer_spy,
          recruitment_cycle_serializer: recruitment_cycle_serializer_spy,
        )
      end

      it "serializes a course object using specified serializers" do
        expect(service.execute(course)).to eq(course_jsonapi)
        expect(renderer).to have_received(:render)
                              .with(course, class: class_serializers)
      end

      it "returns the hash of classes needed for serializing courses" do
        expect(service.execute).to eq(class_serializers)
      end
    end
  end
end
