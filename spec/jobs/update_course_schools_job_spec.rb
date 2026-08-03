require "rails_helper"

RSpec.describe UpdateCourseSchoolsJob, type: :job do
  let(:course) { create(:course) }
  let(:params) { { "school_uuids" => [SecureRandom.uuid] } }

  it "calls the course school update service" do
    allow(Course).to receive(:find).and_return(course)
    allow(Publish::Schools::UpdateCourseSchoolsService).to receive(:call)

    described_class.new.perform(course.id, params)

    expect(Course).to have_received(:find).with(course.id)
    expect(Publish::Schools::UpdateCourseSchoolsService)
      .to have_received(:call)
      .with(course:, params:)
  end
end
