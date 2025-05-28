require "rails_helper"

RSpec.describe Find::SubjectsHelper, type: :helper do
  describe "#subject_display_name" do
    context "when subject name is 'Modern languages (other)'" do
      it "returns 'Other modern languages'" do
        subject = build(:secondary_subject, subject_name: "Modern languages (other)")
        expect(helper.subject_display_name(subject)).to eq("Other modern languages")
      end
    end

    context "when subject name is different" do
      it "returns the original subject name" do
        subject = build(:secondary_subject, subject_name: "Biology")
        expect(helper.subject_display_name(subject)).to eq("Biology")
      end
    end
  end
end
