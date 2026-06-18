# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolExperienceWizard::Repositories::SchoolExperienceRepository do
  subject(:repository) { described_class.new(record: course) }

  let(:course) { create(:course) }

  describe "#transform_for_read" do
    it "exposes school_experience_required as the boolean experience_required" do
      expect(repository.transform_for_read({ school_experience_required: true })[:experience_required]).to be(true)
      expect(repository.transform_for_read({ school_experience_required: false })[:experience_required]).to be(false)
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
    # In the live flow only a "no" answer (false) reaches this repository from
    # the experience_required step; a "yes" answer is held in the cache
    # repository until the content arrives on the experience_details step.
    context "when experience_required is answered on the experience_required step" do
      it "writes false and clears the content for a 'no' answer" do
        result = repository.transform_for_write({ experience_required: false })
        expect(result[:school_experience_required]).to be(false)
        expect(result[:school_experience_required_content]).to be_nil
      end
    end

    context "when experience_details is sent on the experience_details step" do
      it "stores the content and marks school_experience_required true" do
        result = repository.transform_for_write({ experience_details: "Spend time in a school" })
        expect(result[:school_experience_required_content]).to eq("Spend time in a school")
        expect(result[:school_experience_required]).to be(true)
      end
    end

    context "when nothing is answered" do
      it "does not touch the school_experience columns" do
        result = repository.transform_for_write({ experience_required: nil })
        expect(result).not_to have_key(:school_experience_required)
        expect(result).not_to have_key(:school_experience_required_content)
      end
    end
  end

  describe "round trip through the model" do
    it "persists the content and marks experience required when details are saved" do
      repository.write(experience_details: "Spend time in a school")

      expect(course.reload.school_experience_required).to be(true)
      expect(course.school_experience_required_content).to eq("Spend time in a school")

      data = repository.read
      expect(data[:experience_required]).to be(true)
      expect(data[:experience_details]).to eq("Spend time in a school")
    end

    it "persists 'experience not required' answers and clears any content" do
      course.update!(school_experience_required: true, school_experience_required_content: "stale content")

      repository.write(experience_required: false)

      expect(course.reload.school_experience_required).to be(false)
      expect(course.school_experience_required_content).to be_nil
    end
  end
end
