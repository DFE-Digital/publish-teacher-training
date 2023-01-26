# frozen_string_literal: true

require "rails_helper"

module Find
  describe SubjectsForm do
    describe "validation" do
      it "is not valid when subject codes are not present" do
        form = described_class.new(subjects: [], age_group: "primary")

        expect(form.valid?).to be(false)
      end

      it "is valid when subject codes are present" do
        form = described_class.new(subjects: %w[01 02], age_group: "")

        expect(form.valid?).to be(true)
      end

      it "raises primary error message correctly" do
        form = described_class.new(subjects: [], age_group: "primary")
        form.valid?

        expect(form.errors.full_messages).to eq ["Subjects Select at least one primary subject you want to teach"]
      end

      it "raises secondary error message correctly" do
        form = described_class.new(subjects: [], age_group: "secondary")
        form.valid?

        expect(form.errors.full_messages).to eq ["Subjects Select at least one secondary subject you want to teach"]
      end
    end
  end
end
