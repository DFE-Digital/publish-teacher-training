require "rails_helper"

describe API::V2::SerializableCourse do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
  let(:course)           { create(:course, start_date: Time.now.utc) }
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
    context 'with no subjects' do
      let(:course) { create(:course, subject_count: 0) }
      it { expect(subject["attributes"]).to include("level" => "secondary") }
      it { expect(subject["attributes"]).to include("subjects" => []) }
    end

    context 'with primary subjects' do
      let(:course) { create(:course, subject_count: 0, subjects: [create(:subject, subject_name: "primary")]) }
      it { expect(subject["attributes"]).to include("level" => "primary") }
      it { expect(subject["attributes"]).to include("subjects" => %w[Primary]) }
    end

    context 'with secondary subjects' do
      let(:course) { create(:course, subject_count: 0, subjects: [create(:subject, subject_name: "english")]) }
      it { expect(subject["attributes"]).to include("level" => "secondary") }
      it { expect(subject["attributes"]).to include("subjects" => %w[English]) }
    end

    context 'with further education subjects' do
      let(:course) { create(:course, subject_count: 0, subjects: [create(:further_education_subject)]) }
      it { expect(subject["attributes"]).to include("level" => "further_education") }
      it { expect(subject["attributes"]).to include("subjects" => ["Further education"]) }
    end
  end
end
