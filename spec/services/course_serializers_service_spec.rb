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

  it "returns the hash of classes needed for serializing courses" do
    expect(service.execute).to eq(
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
    )
  end
end
