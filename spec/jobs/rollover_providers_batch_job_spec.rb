# frozen_string_literal: true

require "rails_helper"

RSpec.describe RolloverProvidersBatchJob, type: :job do
  include ActiveJob::TestHelper

  let(:process_summary) { create(:rollover_process_summary) }

  it_behaves_like "a job routed to Solid Queue", queue: "low_priority" do
    let(:solid_queue_job_args) { [%w[ABC], 1, 1] }
  end

  it "enqueues one provider job per provider onto low_priority" do
    expect { described_class.perform_now(%w[ABC DEF], 123, process_summary.id) }
      .to have_enqueued_job(RolloverProviderJob).on_queue("low_priority").exactly(2).times
  end
end
