require "rails_helper"

describe Courses::AssignableSubjectService do
  let(:service) do
    described_class.new(
      primary_subject: primary_model,
      secondary_subject: secondary_model,
      further_education_subject: further_education_model,
      modern_language_subject: modern_language_model,
      modern_languages_parent_subject:
    )
  end
  let(:primary_model) { spy(all: []) }
  let(:secondary_model) { spy }
  let(:further_education_model) { spy(all: []) }
  let(:modern_language_model) { spy }
  let(:modern_languages_parent_subject) { spy }

  it "gets all primary subjects if the level is primary" do
    course = create(:course, level: "primary")

    expect(service.execute(course:)).to eq([])
    expect(primary_model).to have_received(:all)
  end

  context "secondary subjects" do
    let(:secondary_model) { SecondarySubject }
    let(:modern_language_model) { ModernLanguagesSubject }
    let!(:modern_languages_parent_subject) { find_or_create(:secondary_subject, subject_name: "Modern Languages", type: :SecondarySubject).becomes(SecondarySubject) }
    let!(:biology) { find_or_create(:secondary_subject, subject_name: "Biology", type: :SecondarySubject).becomes(SecondarySubject) }
    let!(:arabic) { find_or_create(:modern_languages_subject, subject_name: "French").becomes(ModernLanguagesSubject) }

    it "returns subjects other than modern language", without_subjects: true do
      course = build(:course, level: "secondary", infer_subjects?: false)
      expect(service.execute(course:)).to match_array([biology, arabic])
    end
  end

  it "gets all further education subjects if the level is further education" do
    course = create(:course, level: "further_education")

    expect(service.execute(course:)).to eq([])
    expect(further_education_model).to have_received(:all)
  end
end
