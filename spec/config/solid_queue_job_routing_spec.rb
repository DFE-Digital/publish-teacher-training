# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Solid Queue job routing" do
  def ptt_job_classes
    jobs_root = Rails.root.join("app/jobs")

    Dir[jobs_root.join("**/*.rb")].filter_map do |path|
      name = Pathname(path).relative_path_from(jobs_root).sub_ext("").to_s.camelize
      name unless name == "ApplicationJob"
    end
  end

  it "routes every PTT-owned job explicitly to Solid Queue" do
    unrouted = ptt_job_classes.reject do |name|
      job = name.constantize
      job < ApplicationJob && job.queue_adapter_name == "solid_queue"
    end

    expect(unrouted).to be_empty
  end

  it "keeps rollover and backfill fan-out on the low_priority worker" do
    fan_out = [RolloverProvidersBatchJob, RolloverProviderJob, BlankCoordinatesBackfill::BatchJob]

    expect(fan_out.map(&:queue_name)).to all(eq("low_priority"))
  end
end
