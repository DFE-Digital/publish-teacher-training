# frozen_string_literal: true

require "rails_helper"

RSpec.describe BlankCoordinatesBackfill::BatchJob, type: :job do
  it_behaves_like "a job routed to Solid Queue", queue: "low_priority" do
    let(:solid_queue_job_args) { [[{ type: "Site", id: 1 }], 1, true] }
  end
end
