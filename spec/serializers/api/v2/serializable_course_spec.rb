require "rails_helper"

describe API::V2::SerializableCourse do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
  let(:enrichment)       { build :course_enrichment }
  let(:course)           do
    create(:course, enrichments: [enrichment], start_date: Time.now.utc)
  end
  let(:course_json) do
    jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse
      }
    ).to_json
  end
  let(:parsed_json) { JSON.parse(course_json) }

  subject { parsed_json['data'] }

  it { should have_type('courses') }
  it {
    should have_attributes(:start_date, :content_status, :ucas_status,
                           :funding, :subjects, :applications_open_from, :is_send?, :level)
  }

  context 'with a provider' do
    let(:provider) { course.provider }
    let(:course_json) do
      jsonapi_renderer.render(
        course,
        class: {
          Course:   API::V2::SerializableCourse,
          Provider: API::V2::SerializableProvider
        },
        include: [
          :provider
        ]
      ).to_json
    end

    it { should have_relationship(:provider) }

    it 'includes the provider' do
      expect(parsed_json['included'])
        .to(include(have_type('providers')
          .and(have_id(provider.id.to_s))))
    end
  end

  context 'with an accrediting_provider' do
    let(:course) { create(:course, :with_accrediting_provider) }
    let(:accrediting_provider) { course.accrediting_provider }
    let(:course_json) do
      jsonapi_renderer.render(
        course,
        class: {
          Course:   API::V2::SerializableCourse,
          Provider: API::V2::SerializableProvider
        },
        include: [
          :accrediting_provider
        ]
      ).to_json
    end

    it { should have_relationship(:accrediting_provider) }
  end

  context "funding" do
    context "fee-paying" do
      let(:course) { create(:course) }

      it { expect(subject["attributes"]).to include("funding" => "fee") }
    end

    context "apprenticeship" do
      let(:course) { create(:course, :with_apprenticeship) }

      it { expect(subject["attributes"]).to include("funding" => "apprenticeship") }
    end

    context "salaried" do
      let(:course) { create(:course, :with_salary) }

      it { expect(subject["attributes"]).to include("funding" => "salary") }
    end
  end

  describe "#is_send?" do
    let(:course) { create(:course, subject_count: 0) }
    it { expect(subject["attributes"]).to include("is_send?" => false) }

    context "with a SEND subject" do
      let(:course) { create(:course, subject_count: 0, subjects: [create(:send_subject)]) }
      it { expect(subject["attributes"]).to include("is_send?" => true) }
    end
  end

  context "subjects & level" do
    let(:course) { create(:course, subject_count: 0, subjects: subjects) }

    describe 'are taken from the course' do
      let(:subjects) { [create(:subject, subject_name: "primary")] }
      it { expect(subject["attributes"]).to include("level" => "primary") }
      it { expect(subject["attributes"]).to include("subjects" => %w[Primary]) }
    end

    describe 'determine bursary and scholarship info' do
      let(:subjects) { [create(:subject, subject_name: "Secondary"), create(:subject, subject_name: "Russian")] }
      it { expect(subject["attributes"]).to include("has_bursary?" => true) }
      it { expect(subject["attributes"]).to include("has_scholarship_and_bursary?" => false) }
    end
  end

  describe 'attributes retrieved from enrichments' do
    subject { parsed_json['data']['attributes'] }

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
    its(%w[required_qualifications])    { should eq enrichment.qualifications }
    its(%w[salary_details])             { should eq enrichment.salary_details }
  end
end
