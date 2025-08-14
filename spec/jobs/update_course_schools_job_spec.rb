require "rails_helper"

RSpec.describe UpdateCourseSchoolsJob, type: :job do
  let(:course) { create(:course) }
  let(:params) { { site_ids: [SecureRandom.uuid] } }

  it "calls UpdateCourseSchoolsService with the correct arguments" do
    service_instance = instance_double(Publish::Schools::UpdateCourseSchoolsService)

    allow(Course).to receive(:find).and_return(course)
    allow(Publish::Schools::UpdateCourseSchoolsService)
      .to receive(:new)
      .and_return(service_instance)
    allow(service_instance).to receive(:call)

    described_class.new.perform(course.id, params)

    expect(Course).to have_received(:find).with(course.id)
    expect(Publish::Schools::UpdateCourseSchoolsService)
      .to have_received(:new)
      .with(course: course, params: params)
    expect(service_instance).to have_received(:call)
  end
end
