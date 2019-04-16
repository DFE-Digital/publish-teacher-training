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
  it { should have_attributes(:start_date, :content_status, :ucas_status, :funding) }

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
end
