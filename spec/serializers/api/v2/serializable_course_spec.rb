require "rails_helper"

describe API::V2::SerializableCourse do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
  let(:course)           { create(:course, start_date: Time.now.utc) }
  let(:provider)         { course.provider }
  let(:course_json) do
    jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse,
        Provider: API::V2::SerializableProvider
      },
      include: [
        :provider
      ]
    ).to_json
  end
  let(:parsed_json) { JSON.parse(course_json) }

  subject { parsed_json['included'] }

  it { should include(have_type('providers').and(have_id(provider.id.to_s))) }

  describe 'data' do
    subject { parsed_json['data'] }

    it { should have_type('courses') }
    it { should have_attributes(:start_date, :content_status, :ucas_status) }
  end
end
