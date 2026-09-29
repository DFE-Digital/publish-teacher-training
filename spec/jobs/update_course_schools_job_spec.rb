# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateCourseSchoolsJob, type: :job do
  let!(:course) { create(:course) }
  let(:school_uuids) { [SecureRandom.uuid] }

  it "uses Solid Queue explicitly for this pilot job" do
    expect(described_class.queue_adapter).to be_a(ActiveJob::QueueAdapters::SolidQueueAdapter)
  end

  it "can be enqueued onto Solid Queue" do
    expect {
      described_class.perform_later(course.id, school_uuids)
    }.to change { SolidQueue::Job.where(class_name: "UpdateCourseSchoolsJob").count }.by(1)

    job = SolidQueue::Job.where(class_name: "UpdateCourseSchoolsJob").order(:id).last
    expect(job.queue_name).to eq("default")
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
