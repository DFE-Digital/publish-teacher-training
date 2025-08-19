# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::CourseInterviewLocationHelper, type: :helper do
  describe "#display_interview_location" do
    it "returns the correct label for in person interviews" do
      expect(helper.display_interview_location("in person")).to eq("In person")
    end

    it "returns the correct label for online interviews" do
      expect(helper.display_interview_location("online")).to eq("Online")
    end

    it "returns the correct label for both interview types" do
      expect(helper.display_interview_location("both")).to eq("Either in person or online")
    end

    it "returns a humanized version for unknown values" do
      expect(helper.display_interview_location("unknown location")).to eq("Unknown location")
    end
  end
end
