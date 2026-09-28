# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Solid Queue job routing" do
  # Moved in later card 7 tranches; remove each entry as its job moves.
  def not_yet_routed
    %w[
      BulkUpdateCourseSchoolsJob
      EmailAlertMailerJob
      SendWeeklyEmailAlertsJob
      RolloverJob
      RolloverProvidersBatchJob
      RolloverProviderJob
      RolloverMonitoringJob
      BlankCoordinatesBackfill::BackfillJob
      BlankCoordinatesBackfill::BatchJob
      BlankCoordinatesBackfill::MonitoringJob
    ]
  end

  def ptt_job_classes
    jobs_root = Rails.root.join("app/jobs")

    Dir[jobs_root.join("**/*.rb")].filter_map do |path|
      name = Pathname(path).relative_path_from(jobs_root).sub_ext("").to_s.camelize
      name unless name == "ApplicationJob"
    end
  end

  it "routes every PTT-owned job explicitly to Solid Queue" do
    unrouted = (ptt_job_classes - not_yet_routed).reject do |name|
      job = name.constantize
      job < ApplicationJob && job.queue_adapter_name == "solid_queue"
    end

    expect(unrouted).to be_empty
  end
end
