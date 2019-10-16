require "rails_helper"

describe "PrimarySubject factory" do
  subject { create(:primary_subject) }

  it { should be_instance_of(PrimarySubject) }
  it { should be_valid }

  context "primary" do
    subject { create(:primary_subject, :primary) }
    its(:subject_name) { should eq("Primary") }
    its(:subject_code) { should eq("00") }
  end

  context "primary_with_english" do
    subject { create(:primary_subject, :primary_with_english) }
    its(:subject_name) { should eq("Primary with English") }
    its(:subject_code) { should eq("01") }
  end

  context "primary_with_geography_and_history" do
    subject { create(:primary_subject, :primary_with_geography_and_history) }
    its(:subject_name) { should eq("Primary with geography and history") }
    its(:subject_code) { should eq("02") }
  end

  context "primary_with_mathematics" do
    subject { create(:primary_subject, :primary_with_mathematics) }
    its(:subject_name) { should eq("Primary with mathematics") }
    its(:subject_code) { should eq("03") }
  end

  context "primary_with_modern_languages" do
    subject { create(:primary_subject, :primary_with_modern_languages) }
    its(:subject_name) { should eq("Primary with modern languages") }
    its(:subject_code) { should eq("04") }
  end

  context "primary_with_physical_education" do
    subject { create(:primary_subject, :primary_with_physical_education) }
    its(:subject_name) { should eq("Primary with physical education") }
    its(:subject_code) { should eq("06") }
  end

  context "primary_with_science" do
    subject { create(:primary_subject, :primary_with_science) }
    its(:subject_name) { should eq("Primary with science") }
    its(:subject_code) { should eq("07") }
  end
end
