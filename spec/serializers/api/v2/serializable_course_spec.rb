require "rails_helper"

describe API::V2::SerializableCourse do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
  let(:enrichment)       { build :course_enrichment }
  let(:date_today) { Time.zone.today }
  let(:time_now) { Time.now.utc }
  let(:course) do
    create(:course, enrichments: [enrichment], start_date: time_now, applications_open_from: date_today, level: :primary)
  end
  let(:course_json) do
    jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse,
      },
    ).to_json
  end
  let(:parsed_json) { JSON.parse(course_json) }

  subject { parsed_json["data"] }

  it { should have_type("courses") }
  it { should have_attribute(:start_date).with_value(time_now.strftime("%B %Y")) }
  it { should have_attribute :content_status }
  it { should have_attribute :ucas_status }
  it { should have_attribute :funding_type }
  it { should have_attribute(:applications_open_from).with_value(date_today.to_s) }
  it { should have_attribute :is_send? }
  it { should have_attribute(:level).with_value("primary") }
  it { should have_attribute :english }
  it { should have_attribute :maths }
  it { should have_attribute :science }
  it { should have_attribute :gcse_subjects_required }
  it { should have_attribute :provider_code }
  it { should have_attribute :age_range_in_years }
  it { should have_attribute(:recruitment_cycle_year).with_value(course.recruitment_cycle.year) }

  context "with a provider" do
    let(:provider) { course.provider }
    let(:course_json) do
      jsonapi_renderer.render(
        course,
        class: {
          Course:   API::V2::SerializableCourse,
          Provider: API::V2::SerializableProvider,
        },
        include: [
          :provider,
        ],
      ).to_json
    end

    it { should have_relationship(:provider) }

    it "includes the provider" do
      expect(parsed_json["included"])
        .to(include(have_type("providers")
          .and(have_id(provider.id.to_s))))
    end
  end

  context "with a subject" do
    let(:course) { create(:course, subjects: [find_or_create(:primary_subject, :primary_with_mathematics)]) }
    let(:accrediting_provider) { course.accrediting_provider }
    let(:course_json) do
      jsonapi_renderer.render(
        course,
        class: {
          Course: API::V2::SerializableCourse,
          Subject: API::V2::SerializableSubject,
          PrimarySubject: API::V2::SerializableSubject,
        },
        include: [
          :subjects,
        ],
      ).to_json
    end

    it { should have_relationship(:accrediting_provider) }
  end

  context "with an accrediting_provider" do
    let(:course) { create(:course, :with_accrediting_provider) }
    let(:accrediting_provider) { course.accrediting_provider }
    let(:course_json) do
      jsonapi_renderer.render(
        course,
        class: {
          Course:   API::V2::SerializableCourse,
          Provider: API::V2::SerializableProvider,
        },
        include: [
          :accrediting_provider,
        ],
      ).to_json
    end

    it { should have_relationship(:accrediting_provider) }
  end

  context "with a site_status" do
    let(:course) { create(:course, site_statuses: [site_status]) }
    let(:site_status) { create(:site_status) }
    let(:course_json) do
      jsonapi_renderer.render(
        course,
        class: {
          Course:   API::V2::SerializableCourse,
          Provider: API::V2::SerializableProvider,
        },
        include: [
          :site_status,
        ],
      ).to_json
    end

    it { should have_relationship(:site_statuses) }
  end

  context "with a site" do
    let(:course) { create(:course, sites: [site]) }
    let(:site) { create(:site) }
    let(:course_json) do
      jsonapi_renderer.render(
        course,
        class: {
          Course:   API::V2::SerializableCourse,
          Provider: API::V2::SerializableProvider,
        },
        include: [
          :site,
        ],
      ).to_json
    end

    it { should have_relationship(:sites) }
  end

  context "funding_type" do
    context "fee-paying" do
      let(:course) { create(:course) }

      it { expect(subject["attributes"]).to include("funding_type" => "apprenticeship") }
    end

    context "apprenticeship" do
      let(:course) { create(:course, :with_apprenticeship) }

      it { expect(subject["attributes"]).to include("funding_type" => "apprenticeship") }
    end

    context "salaried" do
      let(:course) { create(:course, :with_salary) }

      it { expect(subject["attributes"]).to include("funding_type" => "salary") }
    end
  end

  describe "#is_send?" do
    let(:course) { create(:course) }
    it { expect(subject["attributes"]).to include("is_send?" => false) }

    context "with a SEND subject" do
      let(:course) { create(:course, is_send: true) }
      it { expect(subject["attributes"]).to include("is_send?" => true) }
    end
  end

  # TODO: level now drives the valid subjects that can be assigned to a
  #       given course
  # TODO: bursary and scholarship info should now live in the database
  # TODO: chase up FINANCIAL_SUPPORT
  xcontext "subjects & level" do
    let(:course) { create(:course, subjects: subjects) }

    describe "are taken from the course" do
      let(:subjects) { [find_or_create(:primary_subject, :primary)] }
      it { expect(subject["attributes"]).to include("level" => "primary") }
      it { expect(subject["attributes"]).to include("subjects" => %w[Primary]) }
    end

    describe "determine bursary and scholarship info" do
      let(:subjects) { [find_or_create(:ucas_subject, :secondary), find_or_create(:ucas_subject, subject_name: "Russian")] }
      it { expect(subject["attributes"]).to include("has_bursary?" => true) }
      it { expect(subject["attributes"]).to include("has_scholarship_and_bursary?" => false) }
    end
  end

  describe "attributes retrieved from enrichments" do
    subject { parsed_json["data"]["attributes"] }

    its(%w[about_course])               { should eq enrichment.about_course }
    its(%w[course_length])              { should eq enrichment.course_length }
    its(%w[fee_details])                { should eq enrichment.fee_details }
    its(%w[fee_international])          { should eq enrichment.fee_international }
    its(%w[fee_uk_eu])                  { should eq enrichment.fee_uk_eu }
    its(%w[financial_support])          { should eq enrichment.financial_support }
    its(%w[how_school_placements_work]) { should eq enrichment.how_school_placements_work }
    its(%w[interview_process])          { should eq enrichment.interview_process }
    its(%w[other_requirements])         { should eq enrichment.other_requirements }
    its(%w[personal_qualities])         { should eq enrichment.personal_qualities }
    its(%w[required_qualifications])    { should eq enrichment.required_qualifications }
    its(%w[salary_details])             { should eq enrichment.salary_details }
  end

  context "a new course" do
    let(:provider) { create :provider }
    let(:course) { Course.new(provider: provider) }

    subject { parsed_json["data"] }

    it { should have_attribute(:start_date).with_value(nil) }
  end
end
