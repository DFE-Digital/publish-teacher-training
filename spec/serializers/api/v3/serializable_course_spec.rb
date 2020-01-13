require "rails_helper"

describe API::V3::SerializableCourse do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
  let(:draft_enrichment) { build :course_enrichment }
  let(:published_enrichment) { build :course_enrichment, :published }
  let(:date_today) { Time.zone.today }
  let(:time_now) { Time.now.utc }
  let(:course) do
    create(:course, enrichments: [draft_enrichment, published_enrichment], start_date: time_now, applications_open_from: date_today, level: :primary)
  end
  let(:course_json) do
    jsonapi_renderer.render(
      course,
      class: {
        Course: API::V3::SerializableCourse,
      },
    ).to_json
  end
  let(:parsed_json) { JSON.parse(course_json) }

  subject { parsed_json["data"] }

  it { is_expected.to have_type("courses") }
  it { is_expected.to have_attribute(:start_date).with_value(time_now.strftime("%B %Y")) }
  it { is_expected.to have_attribute :content_status }
  it { is_expected.to have_attribute :ucas_status }
  it { is_expected.to have_attribute :funding_type }
  it { is_expected.to have_attribute(:applications_open_from).with_value(date_today.to_s) }
  it { is_expected.to have_attribute :is_send? }
  it { is_expected.to have_attribute(:level).with_value("primary") }
  it { is_expected.to have_attribute :english }
  it { is_expected.to have_attribute :maths }
  it { is_expected.to have_attribute :science }
  it { is_expected.to have_attribute :gcse_subjects_required }
  it { is_expected.to have_attribute :provider_code }
  it { is_expected.to have_attribute :age_range_in_years }
  it { is_expected.to have_attribute(:recruitment_cycle_year).with_value(course.recruitment_cycle.year) }

  context "with a provider" do
    let(:provider) { course.provider }
    let(:course_json) do
      jsonapi_renderer.render(
        course,
        class: {
          Course:   API::V3::SerializableCourse,
          Provider: API::V2::SerializableProvider,
        },
        include: [
          :provider,
        ],
      ).to_json
    end

    it { is_expected.to have_relationship(:provider) }

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
          Course: API::V3::SerializableCourse,
          Subject: API::V2::SerializableSubject,
          PrimarySubject: API::V2::SerializableSubject,
        },
        include: [
          :subjects,
        ],
      ).to_json
    end

    it { is_expected.to have_relationship(:accrediting_provider) }
  end

  context "with an accrediting_provider" do
    let(:course) { create(:course, :with_accrediting_provider) }
    let(:accrediting_provider) { course.accrediting_provider }
    let(:course_json) do
      jsonapi_renderer.render(
        course,
        class: {
          Course:   API::V3::SerializableCourse,
          Provider: API::V2::SerializableProvider,
        },
        include: [
          :accrediting_provider,
        ],
      ).to_json
    end

    it { is_expected.to have_relationship(:accrediting_provider) }
  end

  context "with a site_status" do
    let(:course) { create(:course, site_statuses: [site_status]) }
    let(:site_status) { create(:site_status) }
    let(:course_json) do
      jsonapi_renderer.render(
        course,
        class: {
          Course:   API::V3::SerializableCourse,
          Provider: API::V2::SerializableProvider,
        },
        include: [
          :site_status,
        ],
      ).to_json
    end

    it { is_expected.to have_relationship(:site_statuses) }
  end

  context "with a site" do
    let(:course) { create(:course, sites: [site]) }
    let(:site) { create(:site) }
    let(:course_json) do
      jsonapi_renderer.render(
        course,
        class: {
          Course:   API::V3::SerializableCourse,
          Provider: API::V2::SerializableProvider,
        },
        include: [
          :site,
        ],
      ).to_json
    end

    it { is_expected.to have_relationship(:sites) }
  end

  context "funding_type" do
    context "fee-paying" do
      let(:course) { create(:course, :fee_type_based) }

      it { expect(subject["attributes"]).to include("funding_type" => "fee") }
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

    it { expect(subject["about_course"]).to               eq(published_enrichment.about_course) }
    it { expect(subject["about_course"]).to               eq published_enrichment.about_course }
    it { expect(subject["course_length"]).to              eq published_enrichment.course_length }
    it { expect(subject["fee_details"]).to                eq published_enrichment.fee_details }
    it { expect(subject["fee_international"]).to          eq published_enrichment.fee_international }
    it { expect(subject["fee_uk_eu"]).to                  eq published_enrichment.fee_uk_eu }
    it { expect(subject["financial_support"]).to          eq published_enrichment.financial_support }
    it { expect(subject["how_school_placements_work"]).to eq published_enrichment.how_school_placements_work }
    it { expect(subject["interview_process"]).to          eq published_enrichment.interview_process }
    it { expect(subject["other_requirements"]).to         eq published_enrichment.other_requirements }
    it { expect(subject["personal_qualities"]).to         eq published_enrichment.personal_qualities }
    it { expect(subject["required_qualifications"]).to    eq published_enrichment.required_qualifications }
    it { expect(subject["salary_details"]).to             eq published_enrichment.salary_details }
  end

  context "a new course" do
    let(:provider) { create :provider }
    let(:course) { Course.new(provider: provider) }

    subject { parsed_json["data"] }

    it { is_expected.to have_attribute(:start_date).with_value(nil) }
  end
end
