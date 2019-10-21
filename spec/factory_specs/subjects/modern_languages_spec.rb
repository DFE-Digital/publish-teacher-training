require "rails_helper"

describe "ModernLanguagesSubject factory" do
  subject { find_or_create(:modern_languages_subject) }

  it { should be_instance_of(ModernLanguagesSubject) }
  it { should be_valid }

  context "french" do
    subject { find_or_create(:modern_languages_subject, :french) }
    its(:subject_name) { should eq("French") }
    its(:subject_code) { should eq("15") }
  end

  context "english_as_a_second_lanaguge_or_other_language" do
    subject { find_or_create(:modern_languages_subject, :english_as_a_second_lanaguge_or_other_language) }
    its(:subject_name) { should eq("English as a second or other language") }
    its(:subject_code) { should eq("16") }
  end

  context "german" do
    subject { find_or_create(:modern_languages_subject, :german) }
    its(:subject_name) { should eq("German") }
    its(:subject_code) { should eq("17") }
  end

  context "italian" do
    subject { find_or_create(:modern_languages_subject, :italian) }
    its(:subject_name) { should eq("Italian") }
    its(:subject_code) { should eq("18") }
  end

  context "japanese" do
    subject { find_or_create(:modern_languages_subject, :japanese) }
    its(:subject_name) { should eq("Japanese") }
    its(:subject_code) { should eq("19") }
  end

  context "mandarin" do
    subject { find_or_create(:modern_languages_subject, :mandarin) }
    its(:subject_name) { should eq("Mandarin") }
    its(:subject_code) { should eq("20") }
  end

  context "russian" do
    subject { find_or_create(:modern_languages_subject, :russian) }
    its(:subject_name) { should eq("Russian") }
    its(:subject_code) { should eq("21") }
  end

  context "spanish" do
    subject { find_or_create(:modern_languages_subject, :spanish) }
    its(:subject_name) { should eq("Spanish") }
    its(:subject_code) { should eq("22") }
  end

  context "modern_languages_other" do
    subject { find_or_create(:modern_languages_subject, :modern_languages_other) }
    its(:subject_name) { should eq("Modern languages (other)") }
    its(:subject_code) { should eq("24") }
  end
end
