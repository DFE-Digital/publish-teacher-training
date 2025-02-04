# frozen_string_literal: true

require 'rails_helper'

describe GiasImportJob do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  before do
    stub_request(:get, 'https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata20250130.csv')
      .to_return(status: 200, headers: {}, body: file_fixture('lib/gias/downloaded.csv'))
  end

  around do |example|
    Timecop.freeze(Time.zone.local(2025, 1, 31)) { example.run }
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it 'queues the job' do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'runs the job' do
    expect do
      job
      perform_enqueued_jobs
    end.to change(GiasSchool, :count).by(1)
  end
end
