# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchTitlePresentable do
  describe "#title" do
    it "returns a human-readable title based on subjects and location" do
      create_subject!("ZY", "Astrology")
      create_subject!("ZZ", "Zoology")

      recent_search = build(
        :recent_search,
        subjects: %w[ZY ZZ],
        search_attributes: { "location" => "Leeds" },
        radius: 10
      )

      expect(recent_search.title).to eq("Astrology and Zoology courses within 10 miles of Leeds")
    end
  end

  describe "#resolved_subject_names" do
    it "maps subject codes to names via the Subject model" do
      create_subject!("ZZ", "Zoology")

      recent_search = build(:recent_search, subjects: %w[ZZ])

      expect(recent_search.send(:resolved_subject_names)).to eq(["Zoology"])
    end

    it "returns an empty array when subjects are blank" do
      recent_search = build(:recent_search, subjects: [])

      expect(recent_search.send(:resolved_subject_names)).to eq([])
    end
  end

  describe "#location_display_name" do
    it "returns location from search_attributes" do
      recent_search = build(:recent_search, search_attributes: { "location" => "Leeds" })

      expect(recent_search.send(:location_display_name)).to eq("Leeds")
    end

    it "falls back to formatted_address when location is absent" do
      recent_search = build(:recent_search, search_attributes: { "formatted_address" => "Leeds, UK" })

      expect(recent_search.send(:location_display_name)).to eq("Leeds, UK")
    end

    it "returns nil when neither is present" do
      recent_search = build(:recent_search, search_attributes: {})

      expect(recent_search.send(:location_display_name)).to be_nil
    end
  end

  private

  def create_subject!(code, name)
    subject_area = SubjectArea.find_or_create_by!(typename: "SecondarySubject", name: "Secondary")
    Subject.create!(subject_code: code, subject_name: name, type: "SecondarySubject", subject_area:)
  end
end
