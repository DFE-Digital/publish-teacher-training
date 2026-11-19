# frozen_string_literal: true

require "rails_helper"

RSpec.describe Sandbox::CourseAttributesMapper do
  subject(:mapper) { described_class.new(attributes) }

  let(:fixture) { JSON.parse(file_fixture("publish_public_api/course.json").read)["attributes"] }
  let(:attributes) { fixture }

  describe "#course_code" do
    it "is the code from production" do
      expect(mapper.course_code).to eq("RX41")
    end
  end

  describe "#uuid" do
    it "is the uuid from production" do
      expect(mapper.uuid).to eq("030a7eef-dba0-4365-a62b-1252401114a0")
    end
  end

  describe "#course_attributes" do
    subject(:course_attributes) { mapper.course_attributes }

    it "maps the production course onto course columns" do
      expect(course_attributes).to include(
        "name" => "Modern languages (Spanish, French)",
        "level" => "secondary",
        "study_mode" => "full_time",
        "funding" => "fee",
        "program_type" => "higher_education_programme",
        "qualification" => "pgce_with_qts",
        "age_range_in_years" => "11_to_16",
        "start_date" => Date.new(2027, 9, 1),
        "degree_grade" => "two_two",
        "degree_type" => "postgraduate",
        "is_send" => false,
        "application_status" => "open",
        "accept_pending_gcse" => true,
        "accept_gcse_equivalency" => true,
        "accept_english_gcse_equivalency" => true,
        "accept_maths_gcse_equivalency" => nil,
        "accept_science_gcse_equivalency" => nil,
        "can_sponsor_skilled_worker_visa" => false,
        "can_sponsor_student_visa" => true,
        "visa_sponsorship_application_deadline_at" => "2027-05-23T23:59:59+01:00",
        "accredited_provider_code" => nil,
        "additional_degree_subject_requirements" => true,
      )
      expect(course_attributes["degree_subject_requirements"]).to start_with("Applicants will normally")
      expect(course_attributes["additional_gcse_equivalencies"]).to start_with("International Applicants")
    end

    it "maps the GCSE requirements" do
      expect(course_attributes).to include("english" => "equivalence_test", "maths" => "equivalence_test", "science" => "not_set")
    end

    it "builds a course the model accepts" do
      course = Course.new(course_attributes)

      expect(course).to have_attributes(
        qualification: "pgce_with_qts",
        profpost_flag: "postgraduate",
        program_type: "higher_education_programme",
        maths: "equivalence_test",
        science: "not_set",
      )
    end

    {
      %w[qts] => "qts",
      %w[qts pgce] => "pgce_with_qts",
      %w[qts pgde] => "pgde_with_qts",
      %w[pgce] => "pgce",
      %w[pgde] => "pgde",
      %w[qts undergraduate_degree] => "undergraduate_degree_with_qts",
      %w[undergraduate_degree qts] => "undergraduate_degree_with_qts",
    }.each do |qualifications, qualification|
      context "when the qualifications are #{qualifications.inspect}" do
        let(:attributes) { fixture.merge("qualifications" => qualifications) }

        it { expect(course_attributes["qualification"]).to eq(qualification) }
      end
    end

    context "when the qualifications are not recognised" do
      let(:attributes) { fixture.merge("qualifications" => %w[pgce pgde]) }

      it "raises" do
        expect { course_attributes }.to raise_error(KeyError)
      end
    end

    context "when it is a further education course without an age range" do
      let(:attributes) do
        fixture.merge("level" => "further_education", "age_minimum" => nil, "age_maximum" => nil, "qualifications" => %w[pgce])
      end

      it "leaves the age range blank" do
        expect(course_attributes).to include("level" => "further_education", "age_range_in_years" => nil)
      end
    end

    context "when there are no degree subject requirements" do
      let(:attributes) { fixture.merge("degree_subject_requirements" => nil) }

      it { expect(course_attributes["additional_degree_subject_requirements"]).to be(false) }
    end
  end

  describe "#enrichment_attributes" do
    subject(:enrichment_attributes) { mapper.enrichment_attributes }

    it "maps the production enrichment, with the domestic fee as fee_uk_eu" do
      expect(enrichment_attributes).to include(
        "course_length" => "OneYear",
        "fee_uk_eu" => 10_050,
        "fee_international" => 15_450,
        "interview_location" => "both",
      )
      expect(enrichment_attributes["placement_selection_criteria"]).to start_with("Our dedicated placements team")
      expect(enrichment_attributes).not_to have_key("fee_domestic")
    end

    it "copies the salary and fee details" do
      mapper = described_class.new(fixture.merge("salary_fee_details" => "Paid a salary"))

      expect(mapper.enrichment_attributes).to include("salary_fee_details" => "Paid a salary")
    end

    it "builds an enrichment the model accepts" do
      enrichment = CourseEnrichment.new(enrichment_attributes)

      expect(enrichment).to have_attributes(fee_uk_eu: 10_050, course_length: "OneYear")
    end
  end

  describe "#enrichment_version" do
    it "is 2 when production leaves the version 1 fields out" do
      expect(mapper.enrichment_version).to eq(2)
    end

    it "is 1 when production has version 1 content" do
      mapper = described_class.new(fixture.merge("about_course" => "About the course"))

      expect(mapper.enrichment_version).to eq(1)
    end
  end

  describe "#subject_codes" do
    it "keeps the order production lists them in" do
      expect(mapper.subject_codes).to eq(%w[15 22])
    end
  end
end
