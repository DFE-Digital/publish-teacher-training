require "rails_helper"

RSpec.describe "Track redirects", type: :system do
  include Rails.application.routes.url_helpers

  let(:allowed_hosts) do
    [
      "https://gov.uk",
      "https://getintoteaching.education.gov.uk",
      "https://education-ni.gov.uk",
      "https://teachinscotland.scot",
      "https://educators.wales",
    ]
  end

  it "redirects to allowed external URLs" do
    allowed_hosts.each do |url|
      visit find_track_click_path(url: url, utm_content: "test")

      expect(page.current_url).to start_with(url)
    end
  end

  it "redirects to internal relative URLs" do
    visit find_track_click_path(url: "/secondary", utm_content: "test")

    expect(page).to have_current_path("/secondary", ignore_query: true)
  end

  it "does not redirect to disallowed external URLs" do
    visit find_track_click_path(url: "https://malicious.example.com", utm_content: "test")

    expect(page).to have_current_path(find_root_path, ignore_query: true)
  end

  it "does not redirect if the URL is malformed" do
    visit find_track_click_path(url: "http:///evil.com", utm_content: "test")

    expect(page).to have_current_path(find_root_path, ignore_query: true)
  end

  it "does not redirect if the URL is blank" do
    visit find_track_click_path(url: "", utm_content: "test")

    expect(page).to have_current_path(find_root_path, ignore_query: true)
  end
end
