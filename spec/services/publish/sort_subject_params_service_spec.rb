# frozen_string_literal: true

require "rails_helper"

module Publish
  describe SortSubjectParamsService do
    let(:english) { find_or_create(:secondary_subject, :english) }
    let(:physics) { find_or_create(:secondary_subject, :physics) }
    let(:modern_languages) { find_or_create(:secondary_subject, :modern_languages) }
    let(:design_and_technology) { find_or_create(:secondary_subject, :design_and_technology) }
    let(:french) { find_or_create(:modern_languages_subject, :french) }
    let(:german) { find_or_create(:modern_languages_subject, :german) }
    let(:engineering) { find_or_create(:design_technology_subject, :engineering) }
    let(:food_technology) { find_or_create(:design_technology_subject, :food_technology) }

    let(:course) { create(:course, :secondary) }

    def call(**args)
      described_class.call(course:, **args)
    end

    context "with a single parent subject" do
      it "returns only that subject" do
        result = call(subjects_ids: [english.id])
        expect(result).to eq([english.id.to_s])
      end
    end

    context "with two parent subjects" do
      it "returns them in the given order" do
        result = call(subjects_ids: [physics.id, english.id])
        expect(result).to eq([physics.id.to_s, english.id.to_s])
      end

      it "preserves swapped order" do
        result = call(subjects_ids: [english.id, physics.id])
        expect(result).to eq([english.id.to_s, physics.id.to_s])
      end
    end

    context "with Modern Languages as master and explicit language_ids" do
      it "interleaves languages after Modern Languages" do
        result = call(
          subjects_ids: [modern_languages.id, english.id],
          language_ids: [french.id, german.id],
        )

        expect(result).to eq([
          modern_languages.id.to_s,
          french.id.to_s,
          german.id.to_s,
          english.id.to_s,
        ])
      end
    end

    context "with Modern Languages as subordinate and explicit language_ids" do
      it "interleaves languages after Modern Languages in second position" do
        result = call(
          subjects_ids: [english.id, modern_languages.id],
          language_ids: [french.id],
        )

        expect(result).to eq([
          english.id.to_s,
          modern_languages.id.to_s,
          french.id.to_s,
        ])
      end
    end

    context "with Design and technology as master and explicit design_technology_ids" do
      it "interleaves D&T specialisms after the parent" do
        result = call(
          subjects_ids: [design_and_technology.id, physics.id],
          design_technology_ids: [engineering.id, food_technology.id],
        )

        expect(result).to eq([
          design_and_technology.id.to_s,
          engineering.id.to_s,
          food_technology.id.to_s,
          physics.id.to_s,
        ])
      end
    end

    context "with both Modern Languages and Design and technology" do
      it "groups each parent with its children" do
        result = call(
          subjects_ids: [modern_languages.id, design_and_technology.id],
          language_ids: [french.id],
          design_technology_ids: [engineering.id],
        )

        expect(result).to eq([
          modern_languages.id.to_s,
          french.id.to_s,
          design_and_technology.id.to_s,
          engineering.id.to_s,
        ])
      end
    end

    context "when languages are preserved from all_subjects_ids (no explicit language_ids)" do
      it "extracts languages from all_subjects_ids" do
        result = call(
          subjects_ids: [modern_languages.id, english.id],
          all_subjects_ids: [modern_languages.id, french.id, german.id, english.id],
        )

        expect(result).to eq([
          modern_languages.id.to_s,
          french.id.to_s,
          german.id.to_s,
          english.id.to_s,
        ])
      end
    end

    context "when D&T specialisms are preserved from all_subjects_ids (no explicit design_technology_ids)" do
      it "extracts D&T specialisms from all_subjects_ids" do
        result = call(
          subjects_ids: [design_and_technology.id, physics.id],
          all_subjects_ids: [design_and_technology.id, engineering.id, physics.id],
        )

        expect(result).to eq([
          design_and_technology.id.to_s,
          engineering.id.to_s,
          physics.id.to_s,
        ])
      end
    end

    context "when subjects_ids contain IDs not in edit_course_options" do
      it "filters out invalid parent IDs" do
        result = call(subjects_ids: [english.id, 999_999])
        expect(result).to eq([english.id.to_s])
      end

      it "filters out invalid language IDs" do
        result = call(
          subjects_ids: [modern_languages.id],
          language_ids: [french.id, 999_999],
        )

        expect(result).to eq([
          modern_languages.id.to_s,
          french.id.to_s,
        ])
      end
    end

    context "with string IDs (from form params)" do
      it "handles string inputs the same as integers" do
        result = call(
          subjects_ids: [modern_languages.id.to_s, english.id.to_s],
          language_ids: [french.id.to_s],
        )

        expect(result).to eq([
          modern_languages.id.to_s,
          french.id.to_s,
          english.id.to_s,
        ])
      end
    end

    context "with empty inputs" do
      it "returns an empty array for empty subjects_ids" do
        result = call(subjects_ids: [])
        expect(result).to eq([])
      end

      it "returns an empty array for nil subjects_ids" do
        result = call(subjects_ids: nil)
        expect(result).to eq([])
      end
    end

    context "when Modern Languages is present but no languages are selected" do
      it "returns just the parent subjects without children" do
        result = call(
          subjects_ids: [modern_languages.id, english.id],
          language_ids: [],
        )

        expect(result).to eq([
          modern_languages.id.to_s,
          english.id.to_s,
        ])
      end
    end
  end
end
