require "rails_helper"

describe Courses::CreationService do
  let(:provider) { create(:provider, sites: [site]) }

  let(:site) { build(:site) }

  let(:recruitment_cycle) { provider.recruitment_cycle }

  let(:next_available_course_code) { false }

  subject do
    described_class.call(
      course_params: valid_course_params, provider: provider,
      next_available_course_code: next_available_course_code
    )
  end

  context "primary course" do
    let(:primary_subject) { find_or_create(:primary_subject, :primary) }

    let(:valid_course_params) do
      {
        "age_range_in_years" => "3_to_7",
        "applications_open_from" => recruitment_cycle.application_start_date,
        "funding_type" => "fee",
        "is_send" => "1",
        "level" => "primary",
        "qualification" => "qts",
        "start_date" => "September #{recruitment_cycle.year}",
        "study_mode" => "full_time",
        "sites_ids" => [site.id],
        "subjects_ids" => [primary_subject.id],
        "course_code" => "D0CK",
      }
    end

    it "create the primary course" do
      valid_course_params.except("is_send", "sites_ids", "subjects_ids", "course_code").each do |key, value|
        expect(subject.public_send(key)).to eq(value)
      end

      expect(subject.is_send).to be(true)
      expect(subject.sites.map(&:id)).to eq([site.id])
      expect(subject.subjects.map(&:id)).to eq([primary_subject.id])
      expect(subject.course_code).to be_nil
      expect(subject.name).to eq("Primary (SEND)")
      expect(subject.errors).to be_empty
    end

    context "next_available_course_code is true" do
      let(:next_available_course_code) do
        true
      end

      it "create the primary course" do
        valid_course_params.except("is_send", "sites_ids", "subjects_ids", "course_code").each do |key, value|
          expect(subject.public_send(key)).to eq(value)
        end

        expect(subject.is_send).to be(true)
        expect(subject.sites.map(&:id)).to eq([site.id])
        expect(subject.subjects.map(&:id)).to eq([primary_subject.id])
        expect(subject.course_code).not_to be_nil
        expect(subject.course_code).not_to eq("D0CK")
        expect(subject.name).to eq("Primary (SEND)")
        expect(subject.errors).to be_empty
      end
    end
  end

  context "secondary course" do
    let(:secondary_subject) { find_or_create(:secondary_subject, :biology) }

    let(:valid_course_params) do
      {
        "age_range_in_years" => "12_to_17",
        "applications_open_from" => recruitment_cycle.application_start_date,
        "funding_type" => "salary",
        "is_send" => "0",
        "level" => "secondary",
        "qualification" => "pgce_with_qts",
        "start_date" => "September #{recruitment_cycle.year}",
        "study_mode" => "part_time",
        "sites_ids" => [site.id],
        "subjects_ids" => [secondary_subject.id],
        "course_code" => "D0CK",
      }
    end

    it "create the secondary course" do
      valid_course_params.except("is_send", "sites_ids", "subjects_ids", "course_code").each do |key, value|
        expect(subject.send(key)).to eq(value)
      end

      expect(subject.is_send).to be(false)
      expect(subject.sites.map(&:id)).to eq([site.id])
      expect(subject.subjects.map(&:id)).to eq([secondary_subject.id])
      expect(subject.course_code).to be_nil
      expect(subject.name).to eq("Biology")
      expect(subject.errors).to be_empty
    end

    context "next_available_course_code is true" do
      let(:next_available_course_code) do
        true
      end

      it "create the secondary course" do
        valid_course_params.except("is_send", "sites_ids", "subjects_ids", "course_code").each do |key, value|
          expect(subject.public_send(key)).to eq(value)
        end

        expect(subject.is_send).to be(false)
        expect(subject.sites.map(&:id)).to eq([site.id])
        expect(subject.subjects.map(&:id)).to eq([secondary_subject.id])
        expect(subject.course_code).not_to be_nil
        expect(subject.course_code).not_to eq("D0CK")
        expect(subject.name).to eq("Biology")
        expect(subject.errors).to be_empty
      end
    end
  end

  context "further_education course" do
    let(:further_education_subject) { find_or_create(:further_education_subject) }

    let(:valid_course_params) do
      {
        "applications_open_from" => recruitment_cycle.application_start_date,
        "is_send" => "1",
        "level" => "further_education",
        "qualification" => "pgde",
        "start_date" => "September #{recruitment_cycle.year}",
        "study_mode" => "full_time_or_part_time",
        "sites_ids" => [site.id],
      }
    end

    it "create the further_education course" do
      expect(subject.is_send).to be(true)
      expect(subject.sites.map(&:id)).to eq([site.id])
      expect(subject.subjects.map(&:id)).to eq([further_education_subject.id])
      expect(subject.course_code).to be_nil
      expect(subject.name).to eq("Further education (SEND)")
      expect(subject.errors).to be_empty
    end

    context "next_available_course_code is true" do
      let(:next_available_course_code) do
        true
      end

      it "create the further_education course" do
        valid_course_params.except("is_send", "sites_ids", "course_code").each do |key, value|
          expect(subject.send(key)).to eq(value)
        end

        expect(subject.is_send).to be(true)
        expect(subject.sites.map(&:id)).to eq([site.id])
        expect(subject.subjects.map(&:id)).to eq([further_education_subject.id])
        expect(subject.course_code).not_to be_nil
        expect(subject.course_code).not_to eq("D0CK")
        expect(subject.name).to eq("Further education (SEND)")
        expect(subject.errors).to be_empty
      end
    end
  end
end
