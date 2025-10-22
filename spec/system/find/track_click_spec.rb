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

  it "does not redirect if the URL is acting as relative (protocol-relative)" do
    visit find_track_click_path(url: "//evil.com", utm_content: "test")

    expect(page).to have_current_path(find_root_path, ignore_query: true)
  end

  it "does not redirect if the URL is blank" do
    visit find_track_click_path(url: "", utm_content: "test")

    expect(page).to have_current_path(find_root_path, ignore_query: true)
  end

  context "protocol-relative URL attacks" do
    it "blocks protocol-relative URLs with paths" do
      visit find_track_click_path(url: "//evil.com/phishing", utm_content: "test")

      expect(page).to have_current_path(find_root_path, ignore_query: true)
    end

    it "blocks protocol-relative URLs with ports" do
      visit find_track_click_path(url: "//evil.com:8080", utm_content: "test")

      expect(page).to have_current_path(find_root_path, ignore_query: true)
    end

    it "blocks protocol-relative URLs with @ symbol" do
      visit find_track_click_path(url: "//evil.com@trusted.com", utm_content: "test")

      expect(page).to have_current_path(find_root_path, ignore_query: true)
    end
  end

  context "backslash-based attacks" do
    it "blocks backslash URLs" do
      visit find_track_click_path(url: "\\\\evil.com", utm_content: "test")

      expect(page).to have_current_path(find_root_path, ignore_query: true)
    end

    it "blocks mixed slash URLs" do
      visit find_track_click_path(url: "\\/evil.com", utm_content: "test")

      expect(page).to have_current_path(find_root_path, ignore_query: true)
    end
  end

  describe "whitespace and encoding attacks" do
    it "blocks URLs with leading whitespace" do
      visit find_track_click_path(url: " //evil.com", utm_content: "test")

      expect(page).to have_current_path(find_root_path, ignore_query: true)
    end

    it "blocks URLs with trailing whitespace" do
      visit find_track_click_path(url: "//evil.com ", utm_content: "test")

      expect(page).to have_current_path(find_root_path, ignore_query: true)
    end

    it "blocks URLs with control characters" do
      visit find_track_click_path(url: "\x00//evil.com", utm_content: "test")

      expect(page).to have_current_path(find_root_path, ignore_query: true)
    end

    it "blocks URLs with newlines" do
      visit find_track_click_path(url: "\n//evil.com", utm_content: "test")

      expect(page).to have_current_path(find_root_path, ignore_query: true)
    end
  end

  describe "scheme manipulation attacks" do
    it "blocks URLs with missing // after scheme" do
      visit find_track_click_path(url: "http:evil.com", utm_content: "test")

      expect(page).to have_current_path(find_root_path, ignore_query: true)
    end

    it "blocks URLs with javascript: scheme" do
      visit find_track_click_path(url: "javascript:alert(1)", utm_content: "test")

      expect(page).to have_current_path(find_root_path, ignore_query: true)
    end

    it "blocks URLs with data: scheme" do
      visit find_track_click_path(url: "data:text/html,<script>alert(1)</script>", utm_content: "test")

      expect(page).to have_current_path(find_root_path, ignore_query: true)
    end
  end

  describe "valid relative URLs" do
    it "allows absolute path URLs" do
      visit find_track_click_path(url: "/courses", utm_content: "test")

      expect(page).to have_current_path("/courses", ignore_query: true)
    end

    it "allows absolute path with query parameters" do
      visit find_track_click_path(url: "/courses?filter=primary", utm_content: "test")

      expect(page).to have_current_path("/courses", ignore_query: true)
    end

    it "allows absolute path with fragments" do
      visit find_track_click_path(url: "/courses#section", utm_content: "test")

      expect(page).to have_current_path("/courses", ignore_query: true)
    end

    it "allows relative path URLs" do
      visit find_track_click_path(url: "secondary", utm_content: "test")

      expect(page.current_url).not_to include("evil.com")
    end
  end
end
