# frozen_string_literal: true

require "rails_helper"

describe GiasImportJob do
  subject(:job) { described_class.perform_later }

  before do
    stub_request(:get, "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata20250130.csv")
      .to_return(status: 200, headers: {}, body: file_fixture("lib/gias/downloaded.csv"))
  end

  around do |example|
    Timecop.freeze(Time.zone.local(2025, 1, 31)) { example.run }
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it "queues the job" do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it_behaves_like "a Solid Queue job", queue: "low_priority"

  it "runs the job" do
    expect {
      job
      perform_enqueued_jobs
    }.to change(GiasSchool, :count).by(1)
  end

  it "tries a failed download again later" do
    allow(Gias::Downloader).to receive(:call).and_raise(Gias::DownloadError)

    expect { described_class.perform_now }
      .to have_enqueued_job(described_class).at(a_value_between(30.minutes.from_now, 35.minutes.from_now))
  end

  [
    ActiveRecord::ConnectionFailed,
    ActiveRecord::ConnectionNotEstablished,
    PG::ConnectionBad,
  ].each do |error_class|
    it "tries a transient #{error_class} database failure again later" do
      allow(Gias::Importer).to receive(:call).and_raise(error_class, "database unavailable")

      expect { described_class.perform_now }
        .to have_enqueued_job(described_class).at(a_value_between(5.minutes.from_now, 6.minutes.from_now))
    end
  end

  it "does not retry other failures" do
    allow(Gias::Downloader).to receive(:call).and_return(StringIO.new)
    allow(Gias::Transformer).to receive(:call).and_raise(ArgumentError)

    expect { described_class.perform_now }.to raise_error(ArgumentError)
    expect(described_class).not_to have_been_enqueued
  end
end
