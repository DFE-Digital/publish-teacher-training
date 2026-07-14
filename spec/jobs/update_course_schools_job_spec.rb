require "rails_helper"

RSpec.describe UpdateCourseSchoolsJob, type: :job do
  let(:course) { create(:course) }
  let(:params) { { school_uuids: [SecureRandom.uuid] } }

  it "calls both update services with the correct arguments" do
    legacy_service_instance = instance_double(Publish::Schools::UpdateCourseSchoolsService)

    allow(Course).to receive(:find).and_return(course)
    allow(Publish::Schools::UpdateCourseSchoolsService)
      .to receive(:new)
      .and_return(legacy_service_instance)
    allow(Publish::Schools::UpdateCourseProviderSchoolsService).to receive(:call)
    allow(legacy_service_instance).to receive(:call)

    described_class.new.perform(course.id, params)

    expect(Course).to have_received(:find).with(course.id)
    expect(Publish::Schools::UpdateCourseSchoolsService)
      .to have_received(:new)
      .with(course: course, params: params)
    expect(legacy_service_instance).to have_received(:call)
    expect(Publish::Schools::UpdateCourseProviderSchoolsService).to have_received(:call).with(course: course, params: params)
  end
end
