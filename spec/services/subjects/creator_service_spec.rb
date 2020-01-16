describe Subjects::CreatorService do
  let(:primary_model) { spy }
  let(:secondary_model) { spy }
  let(:further_education_model) { spy }
  let(:modern_languages_model) { spy }
  let(:discontinued_model) { spy }

  let(:service) do
    described_class.new(
      primary_subject: primary_model,
      secondary_subject: secondary_model,
      further_education_subject: further_education_model,
      modern_languages_subject: modern_languages_model,
      discontinued_subject: discontinued_model,
    )
  end

  it "creates subject data unless subject already exists" do
    service.execute
    expect(primary_model).to have_received(:find_or_create_by).with(subject_name: "Primary", subject_code: "00")
    expect(secondary_model).to have_received(:find_or_create_by).with(subject_name: "Art and design", subject_code: "W1")
    expect(further_education_model).to have_received(:find_or_create_by).with(subject_name: "Further education", subject_code: "41")
    expect(discontinued_model).to have_received(:find_or_create_by).with(subject_name: "Humanities")
  end
end
