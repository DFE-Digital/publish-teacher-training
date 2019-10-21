require "rails_helper"

describe "SecondarySubject factory" do
  subject { find_or_create(:secondary_subject) }

  it { should be_instance_of(SecondarySubject) }
  it { should be_valid }

  context "art_and_design" do
    subject { find_or_create(:secondary_subject, :art_and_design) }
    its(:subject_name) { should eq("Art and design") }
    its(:subject_code) { should eq("W1") }
  end

  context "science" do
    subject { find_or_create(:secondary_subject, :science) }
    its(:subject_name) { should eq("Science") }
    its(:subject_code) { should eq("F0") }
  end

  context "biology" do
    subject { find_or_create(:secondary_subject, :biology) }
    its(:subject_name) { should eq("Biology") }
    its(:subject_code) { should eq("C1") }
  end

  context "business_studies" do
    subject { find_or_create(:secondary_subject, :business_studies) }
    its(:subject_name) { should eq("Business studies") }
    its(:subject_code) { should eq("08") }
  end

  context "chemistry" do
    subject { find_or_create(:secondary_subject, :chemistry) }
    its(:subject_name) { should eq("Chemistry") }
    its(:subject_code) { should eq("F1") }
  end

  context "citizenship" do
    subject { find_or_create(:secondary_subject, :citizenship) }
    its(:subject_name) { should eq("Citizenship") }
    its(:subject_code) { should eq("09") }
  end

  context "classics" do
    subject { find_or_create(:secondary_subject, :classics) }
    its(:subject_name) { should eq("Classics") }
    its(:subject_code) { should eq("Q8") }
  end

  context "communication_and_media_studies" do
    subject { find_or_create(:secondary_subject, :communication_and_media_studies) }
    its(:subject_name) { should eq("Communication and media studies") }
    its(:subject_code) { should eq("P3") }
  end

  context "computing" do
    subject { find_or_create(:secondary_subject, :computing) }
    its(:subject_name) { should eq("Computing") }
    its(:subject_code) { should eq("11") }
  end

  context "dance" do
    subject { find_or_create(:secondary_subject, :dance) }
    its(:subject_name) { should eq("Dance") }
    its(:subject_code) { should eq("12") }
  end

  context "design_and_technology" do
    subject { find_or_create(:secondary_subject, :design_and_technology) }
    its(:subject_name) { should eq("Design and technology") }
    its(:subject_code) { should eq("DT") }
  end

  context "drama" do
    subject { find_or_create(:secondary_subject, :drama) }
    its(:subject_name) { should eq("Drama") }
    its(:subject_code) { should eq("13") }
  end

  context "economics" do
    subject { find_or_create(:secondary_subject, :economics) }
    its(:subject_name) { should eq("Economics") }
    its(:subject_code) { should eq("L1") }
  end

  context "english" do
    subject { find_or_create(:secondary_subject, :english) }
    its(:subject_name) { should eq("English") }
    its(:subject_code) { should eq("Q3") }
  end

  context "geography" do
    subject { find_or_create(:secondary_subject, :geography) }
    its(:subject_name) { should eq("Geography") }
    its(:subject_code) { should eq("F8") }
  end

  context "health_and_social_care" do
    subject { find_or_create(:secondary_subject, :health_and_social_care) }
    its(:subject_name) { should eq("Health and social care") }
    its(:subject_code) { should eq("L5") }
  end

  context "history" do
    subject { find_or_create(:secondary_subject, :history) }
    its(:subject_name) { should eq("History") }
    its(:subject_code) { should eq("V1") }
  end

  context "mathematics" do
    subject { find_or_create(:secondary_subject, :mathematics) }
    its(:subject_name) { should eq("Mathematics") }
    its(:subject_code) { should eq("G1") }
  end

  context "music" do
    subject { find_or_create(:secondary_subject, :music) }
    its(:subject_name) { should eq("Music") }
    its(:subject_code) { should eq("W3") }
  end

  context "philosophy" do
    subject { find_or_create(:secondary_subject, :philosophy) }
    its(:subject_name) { should eq("Philosophy") }
    its(:subject_code) { should eq("P1") }
  end

  context "physical_education" do
    subject { find_or_create(:secondary_subject, :physical_education) }
    its(:subject_name) { should eq("Physical education") }
    its(:subject_code) { should eq("C6") }
  end

  context "physics" do
    subject { find_or_create(:secondary_subject, :physics) }
    its(:subject_name) { should eq("Physics") }
    its(:subject_code) { should eq("F3") }
  end

  context "religious_education" do
    subject { find_or_create(:secondary_subject, :religious_education) }
    its(:subject_name) { should eq("Religious education") }
    its(:subject_code) { should eq("V6") }
  end

  context "social_sciences" do
    subject { find_or_create(:secondary_subject, :social_sciences) }
    its(:subject_name) { should eq("Social sciences") }
    its(:subject_code) { should eq("14") }
  end

  context "modern_languages" do
    subject { find_or_create(:secondary_subject, :modern_languages) }
    its(:subject_name) { should eq("Modern Languages") }
    its(:subject_code) { should eq(nil) }
  end
end
