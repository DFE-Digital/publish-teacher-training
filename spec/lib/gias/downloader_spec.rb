# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gias::Downloader do
  # The downloaded.csv has a windows-1252 character in the school name
  before do
    stub_request(:get, "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata20250129.csv")
      .to_return(status: 200, headers: {}, body: file_fixture("lib/gias/downloaded.csv"))
  end

  around do |example|
    Timecop.freeze(Time.zone.local(2025, 1, 30)) do
      example.run
    end
  end

  let!(:file_name) { "tmp/gias_school-#{Process.pid}.csv" }

  it "downloads the file" do
    FileUtils.rm_f(file_name)
    expect { described_class.call }.to change { File.exist?(file_name) }.from(false).to(true)
  ensure
    FileUtils.rm_f(file_name)
  end

  it "raises DownloadError when request is not success" do
    stub_request(:get, "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata20250129.csv")
      .to_return(status: 301, headers: {})
    expect { described_class.call }.to raise_error(Gias::DownloadError)
  end
end
