# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolExperienceWizard::Repositories::SchoolExperienceRepository do
  subject(:repository) { described_class.new(record: course) }

  let(:course) { create(:course) }

  describe "#transform_for_read" do
    it "converts school_experience_required true to experience_required 'yes'" do
      result = repository.transform_for_read({ school_experience_required: true })
      expect(result[:experience_required]).to eq("yes")
    end

    it "converts school_experience_required false to experience_required 'no'" do
      result = repository.transform_for_read({ school_experience_required: false })
      expect(result[:experience_required]).to eq("no")
    end

    it "leaves experience_required nil when school_experience_required is nil" do
      result = repository.transform_for_read({ school_experience_required: nil })
      expect(result[:experience_required]).to be_nil
    end

    it "exposes school_experience_required_content as experience_details" do
      result = repository.transform_for_read({ school_experience_required_content: "Spend time in a school" })
      expect(result[:experience_details]).to eq("Spend time in a school")
    end
  end

  describe "#transform_for_write" do
    context "when experience is required" do
      it "converts experience_required 'yes' to school_experience_required true" do
        result = repository.transform_for_write({ experience_required: "yes", experience_details: "Spend time in a school" })
        expect(result[:school_experience_required]).to be(true)
      end

      it "drops experience_details so the content is taken from a later step" do
        result = repository.transform_for_write({ experience_required: "yes", experience_details: "Spend time in a school" })
        expect(result).not_to have_key(:experience_details)
      end
    end

    context "when experience is not required" do
      it "converts experience_required 'no' to school_experience_required false" do
        result = repository.transform_for_write({ experience_required: "no" })
        expect(result[:school_experience_required]).to be(false)
      end

      it "clears the school_experience_required_content" do
        result = repository.transform_for_write({ experience_required: "no", experience_details: "stale content" })
        expect(result[:school_experience_required_content]).to be_nil
      end
    end

    context "when experience_required is not answered" do
      it "removes experience_required and clears the content" do
        result = repository.transform_for_write({ experience_required: nil })
        expect(result).not_to have_key(:experience_required)
        expect(result[:school_experience_required_content]).to be_nil
      end
    end

    context "when only experience_details is provided" do
      it "stores experience_details as school_experience_required_content" do
        result = repository.transform_for_write({ experience_details: "Spend time in a school" })
        expect(result[:school_experience_required_content]).to eq("Spend time in a school")
      end
    end
  end

  describe "round trip through the model" do
    it "persists 'experience required' answers and reads them back" do
      repository.write(experience_required: "yes")
      repository.write(experience_details: "Spend time in a school")

      expect(course.reload.school_experience_required).to be(true)
      expect(course.school_experience_required_content).to eq("Spend time in a school")

      data = repository.read
      expect(data[:experience_required]).to eq("yes")
      expect(data[:experience_details]).to eq("Spend time in a school")
    end

    it "persists 'experience not required' answers and clears any content" do
      course.update!(school_experience_required: true, school_experience_required_content: "stale content")

      repository.write(experience_required: "no")

      expect(course.reload.school_experience_required).to be(false)
      expect(course.school_experience_required_content).to be_nil
    end
  end
end
