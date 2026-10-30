require "rails_helper"

RSpec.describe Support::Providers::ManualRolloverForm, type: :model do
  subject { described_class.new(confirmation:, environment:, provider: create(:provider)) }

  let(:confirmation) { "" }
  let(:environment) { "" }

  context "when confirmation is blank" do
    let(:confirmation) { "" }

    it "is invalid" do
      expect(subject).not_to be_valid
      expect(subject.errors[:confirmation]).to include("You must type 'confirm manual rollover' to proceed.")
    end
  end

  context "when confirmation is incorrect" do
    let(:confirmation) { "something else" }

    it "is invalid with custom message" do
      expect(subject).not_to be_valid
      expect(subject.errors[:confirmation]).to include("You must type 'confirm manual rollover' to proceed.")
    end
  end

  context "when environment is blank" do
    let(:environment) { "" }

    it "is invalid" do
      expect(subject).not_to be_valid
      expect(subject.errors[:environment]).to include("You must type the environment name to proceed.")
    end
  end

  context "when environment is incorrect" do
    let(:confirmation) { "something else" }

    it "is invalid with custom message" do
      expect(subject).not_to be_valid
      expect(subject.errors[:environment]).to include("You must type the environment name to proceed.")
    end
  end

  context "when confirmation and environment is correct" do
    let(:confirmation) { "confirm manual rollover" }
    let(:environment) { "test" }

    it "is valid" do
      expect(subject).to be_valid
    end
  end

  context "when the provider has courses" do
    subject { described_class.new(confirmation: "confirm manual rollover", environment: "test", provider:, course_codes:) }

    let(:provider) { create(:provider) }
    let!(:course) { create(:course, provider:) }

    context "and no choice is made" do
      let(:course_codes) { [""] }

      it "asks which courses to roll over" do
        expect(subject).not_to be_valid
        expect(subject.errors[:course_codes]).to eq(["Select which courses to roll over"])
      end
    end

    context "and none is chosen alongside a course" do
      let(:course_codes) { ["", course.course_code, "none"] }

      it "asks for one or the other" do
        expect(subject).not_to be_valid
        expect(subject.errors[:course_codes]).to eq(["Select courses to roll over or select ‘No courses’"])
      end
    end

    context "and a course is chosen that the provider no longer has" do
      let(:course_codes) { ["", course.course_code, "GONE"] }

      it "asks to choose from the list" do
        expect(subject).not_to be_valid
        expect(subject.errors[:course_codes]).to eq(["Select courses from the list"])
      end
    end

    context "and a course is chosen twice" do
      let(:course_codes) { ["", course.course_code, course.course_code] }

      it "rolls it over once" do
        expect(subject).to be_valid
        expect(subject.chosen_course_codes).to eq([course.course_code])
      end
    end
  end
end
