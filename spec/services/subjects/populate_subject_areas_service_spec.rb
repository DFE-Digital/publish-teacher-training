describe Subjects::SubjectAreaCreatorService do
  let(:subject_area_spy) { spy }
  let(:service) { described_class.new(subject_area: subject_area_spy) }

  it "populates subject areas" do
    service.execute
    expect(subject_area_spy).to have_received(:find_or_create_by!).with(typename: "PrimarySubject", name: "Primary")
    expect(subject_area_spy).to have_received(:find_or_create_by!).with(typename: "SecondarySubject", name: "Secondary")
    expect(subject_area_spy).to have_received(:find_or_create_by!).with(typename: "ModernLanguagesSubject", name: "Secondary: Modern Languages")
    expect(subject_area_spy).to have_received(:find_or_create_by!).with(typename: "FurtherEducationSubject", name: "Further Education")
    expect(subject_area_spy).to have_received(:find_or_create_by!).with(typename: "DiscontinuedSubject", name: "Discontinued")
  end
end
