# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateCourseSchoolsJob, type: :job do
  let!(:course) { create(:course) }
  let(:school_uuids) { [SecureRandom.uuid] }

  it_behaves_like "a job routed to Solid Queue", queue: "default" do
    let(:solid_queue_job_args) { [course.id, school_uuids] }
  end

  it "allows the service to skip Provider::Schools removed while the job was queued" do
    allow(Course).to receive(:find).and_return(course)
    allow(Publish::Schools::UpdateCourseSchoolsService).to receive(:call)

    described_class.perform_now(course.id, school_uuids)

    expect(Course).to have_received(:find).with(course.id)
    expect(Publish::Schools::UpdateCourseSchoolsService)
      .to have_received(:call)
      .with(course:, school_uuids:, raise_on_missing_provider_schools: false)
  end
end
