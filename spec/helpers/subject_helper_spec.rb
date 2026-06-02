# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubjectHelper do
  describe ".subject_name_in_sentence" do
    it "down-cases a non-language subject name" do
      expect(described_class.subject_name_in_sentence("Mathematics")).to eq("mathematics")
    end

    it "preserves a single-word language proper noun" do
      expect(described_class.subject_name_in_sentence("French")).to eq("French")
    end

    it "down-cases descriptive words but preserves the language proper noun" do
      expect(described_class.subject_name_in_sentence("Ancient Greek")).to eq("ancient Greek")
      expect(described_class.subject_name_in_sentence("Ancient Hebrew")).to eq("ancient Hebrew")
    end

    it "leaves a name with no alphabetic first character unchanged" do
      expect(described_class.subject_name_in_sentence("3D design")).to eq("3D design")
    end
  end
end
