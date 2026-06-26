# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::WizardParamsSerializer do
  subject(:params) { described_class.call(wizard:) }

  let(:state_overrides) { {} }
  let(:base_state) do
    {
      level: "secondary",
      is_send: "false",
      primary_level?: false,
      further_education_level?: false,
      primary_master_subject_id: nil,
      secondary_master_subject_id: "100",
      subordinate_subject_id: "200",
      modern_languages_specialisms?: false,
      design_technology_specialisms?: false,
      language_ids: nil,
      design_technology_ids: nil,
      age_range_in_years: "11_to_16",
      course_age_range_in_years_other_from: nil,
      course_age_range_in_years_other_to: nil,
      qualification: "pgce_with_qts",
      undergraduate_degree_with_qts?: false,
      funding_type: "salary",
      study_pattern: %w[full_time part_time],
      site_ids: %w[1 2],
      study_sites_ids: %w[3],
      accredited_provider_code: "A0A",
      start_date: "July 2027",
      campaign_name: "no_campaign",
      can_sponsor_student_visa: false,
      can_sponsor_skilled_worker_visa: true,
      visa_sponsorship_application_deadline_required: true,
      visa_sponsorship_application_deadline_at: Date.new(2027, 3, 1),
    }
  end
  let(:state_store) do
    double(
      "CourseWizard::StateStores::CourseWizardStore",
      **base_state.merge(state_overrides),
    )
  end
  let(:wizard) { instance_double(CourseWizard, state_store:, accrediting_provider: nil) }

  describe "key translations" do
    it "maps the canonical wizard keys to creation-service keys" do
      expect(params["master_subject_id"]).to eq("100")
      expect(params["sites_ids"]).to eq(%w[1 2])
      expect(params["study_mode"]).to eq(%w[full_time part_time])
      expect(params["funding"]).to eq("salary")
      expect(params["subordinate_subject_id"]).to eq("200")
    end

    it "passes through supported creation attributes" do
      expect(params["level"]).to eq("secondary")
      expect(params["is_send"]).to eq("false")
      expect(params["qualification"]).to eq("pgce_with_qts")
      expect(params["accredited_provider_code"]).to eq("A0A")
      expect(params["start_date"]).to eq("July 2027")
      expect(params["campaign_name"]).to eq("no_campaign")
      expect(params["can_sponsor_student_visa"]).to be(false)
      expect(params["can_sponsor_skilled_worker_visa"]).to be(true)
      expect(params["visa_sponsorship_application_deadline_required"]).to be(true)
    end
  end

  describe "master subject selection permutations" do
    context "for primary level" do
      let(:state_overrides) { { primary_level?: true, primary_master_subject_id: "900", secondary_master_subject_id: "100" } }

      it "uses the primary master subject id" do
        expect(params["master_subject_id"]).to eq("900")
      end
    end

    context "for secondary level" do
      it "uses the secondary master subject id" do
        expect(params["master_subject_id"]).to eq("100")
      end
    end

    context "for further education" do
      let(:state_overrides) { { further_education_level?: true } }

      it "does not emit master subject id" do
        expect(params["master_subject_id"]).to be_nil
      end
    end
  end

  describe "subjects_ids permutations" do
    it "builds subjects_ids with selected master and subordinate subjects" do
      expect(params["subjects_ids"]).to eq(%w[100 200])
    end

    context "when modern languages and design technology specialisms are active" do
      let(:state_overrides) do
        {
          modern_languages_specialisms?: true,
          design_technology_specialisms?: true,
          language_ids: %w[300],
          design_technology_ids: %w[400],
        }
      end

      it "includes both specialism ids" do
        expect(params["subjects_ids"]).to eq(%w[100 200 300 400])
      end
    end

    context "when specialism ids are present but specialisms are inactive" do
      let(:state_overrides) { { language_ids: %w[300], design_technology_ids: %w[400] } }

      it "does not include stale specialism ids" do
        expect(params["subjects_ids"]).to eq(%w[100 200])
      end
    end

    context "when duplicate subject ids are provided" do
      let(:state_overrides) { { subordinate_subject_id: "100", modern_languages_specialisms?: true, language_ids: %w[100] } }

      it "deduplicates subjects_ids" do
        expect(params["subjects_ids"]).to eq(%w[100])
      end
    end

    context "for further education" do
      let(:state_overrides) { { further_education_level?: true } }

      it "returns empty subjects_ids" do
        expect(params["subjects_ids"]).to eq([])
      end
    end
  end

  describe "age range permutations" do
    context "when not using custom range" do
      it "keeps the original age range key" do
        expect(params["age_range_in_years"]).to eq("11_to_16")
      end
    end

    context "when using custom range with both bounds" do
      let(:state_overrides) do
        { age_range_in_years: "other", course_age_range_in_years_other_from: "14", course_age_range_in_years_other_to: "19" }
      end

      it "maps to combined age range key" do
        expect(params["age_range_in_years"]).to eq("14_to_19")
      end
    end

    context "when using custom range but one bound is missing" do
      let(:state_overrides) do
        { age_range_in_years: "other", course_age_range_in_years_other_from: "14", course_age_range_in_years_other_to: nil }
      end

      it "preserves other value" do
        expect(params["age_range_in_years"]).to eq("other")
      end
    end
  end

  describe "funding permutations" do
    context "for non-TDA" do
      it "uses funding_type directly" do
        expect(params["funding"]).to eq("salary")
      end
    end

    context "for TDA with blank funding_type" do
      let(:state_overrides) { { undergraduate_degree_with_qts?: true, funding_type: nil } }

      it "defaults to apprenticeship funding" do
        expect(params["funding"]).to eq("apprenticeship")
      end
    end
  end

  describe "study mode permutations" do
    context "when study_pattern has values" do
      it "maps study_pattern array to study_mode" do
        expect(params["study_mode"]).to eq(%w[full_time part_time])
      end
    end

    context "when non-TDA and no study_pattern" do
      let(:state_overrides) { { study_pattern: nil, undergraduate_degree_with_qts?: false } }

      it "returns an empty array to trigger legacy validation" do
        expect(params["study_mode"]).to eq([])
      end
    end

    context "when TDA and no study_pattern" do
      let(:state_overrides) { { study_pattern: nil, undergraduate_degree_with_qts?: true } }

      it "defaults to full time study mode" do
        expect(params["study_mode"]).to eq(%w[full_time])
      end
    end
  end

  describe "skilled worker visa defaults" do
    context "when TDA and skilled worker visa is unset" do
      let(:state_overrides) { { undergraduate_degree_with_qts?: true, can_sponsor_skilled_worker_visa: nil } }

      it "defaults to cannot sponsor" do
        expect(params["can_sponsor_skilled_worker_visa"]).to be(false)
      end
    end
  end

  describe "site/study-site permutations" do
    context "when ids include blanks" do
      let(:state_overrides) { { site_ids: ["1", ""], study_sites_ids: ["3", ""] } }

      it "compacts blank ids" do
        expect(params["sites_ids"]).to eq(%w[1])
        expect(params["study_sites_ids"]).to eq(%w[3])
      end
    end

    context "when study sites are nil" do
      let(:state_overrides) { { study_sites_ids: nil } }

      it "does not emit study_sites_ids key" do
        expect(params).not_to have_key("study_sites_ids")
      end
    end
  end

  describe "visa deadline permutations" do
    context "when deadline is a Date-like value" do
      it "maps into multipart date params" do
        expect(params["visa_sponsorship_application_deadline_at(1i)"]).to eq("2027")
        expect(params["visa_sponsorship_application_deadline_at(2i)"]).to eq("3")
        expect(params["visa_sponsorship_application_deadline_at(3i)"]).to eq("1")
        expect(params).not_to have_key("visa_sponsorship_application_deadline_at")
      end
    end

    context "when deadline is a hash with symbol keys" do
      let(:state_overrides) { { visa_sponsorship_application_deadline_at: { year: "2028", month: "4", day: "2" } } }

      it "maps hash into multipart date params" do
        expect(params["visa_sponsorship_application_deadline_at(1i)"]).to eq("2028")
        expect(params["visa_sponsorship_application_deadline_at(2i)"]).to eq("4")
        expect(params["visa_sponsorship_application_deadline_at(3i)"]).to eq("2")
      end
    end

    context "when deadline is a hash with string keys" do
      let(:state_overrides) { { visa_sponsorship_application_deadline_at: { "year" => "2029", "month" => "5", "day" => "3" } } }

      it "maps hash into multipart date params" do
        expect(params["visa_sponsorship_application_deadline_at(1i)"]).to eq("2029")
        expect(params["visa_sponsorship_application_deadline_at(2i)"]).to eq("5")
        expect(params["visa_sponsorship_application_deadline_at(3i)"]).to eq("3")
      end
    end

    context "when deadline value is missing" do
      let(:state_overrides) { { visa_sponsorship_application_deadline_at: nil } }

      it "does not emit deadline multipart params" do
        expect(params).not_to have_key("visa_sponsorship_application_deadline_at(1i)")
        expect(params).not_to have_key("visa_sponsorship_application_deadline_at(2i)")
        expect(params).not_to have_key("visa_sponsorship_application_deadline_at(3i)")
      end
    end

    context "when deadline hash is incomplete" do
      let(:state_overrides) { { visa_sponsorship_application_deadline_at: { year: "2028", month: nil, day: "2" } } }

      it "does not emit deadline multipart params" do
        expect(params).not_to have_key("visa_sponsorship_application_deadline_at(1i)")
        expect(params).not_to have_key("visa_sponsorship_application_deadline_at(2i)")
        expect(params).not_to have_key("visa_sponsorship_application_deadline_at(3i)")
      end
    end
  end
end
