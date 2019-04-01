require "rails_helper"

describe API::V2::SerializableCourse do
  let(:course) { create(:course, start_date: Time.now.utc) }
  let(:resource) { API::V2::SerializableCourse.new object: course }

  it 'sets type to courses' do
    expect(resource.jsonapi_type).to eq :courses
  end

  subject { resource.as_jsonapi.to_json }

  it { should be_json.with_content(type: 'courses') }
  it { should be_json.with_content(course.start_date.iso8601).at_path("attributes.start_date") }
  it { should be_json.with_content(course.content_status.to_s).at_path("attributes.content_status") }
end
