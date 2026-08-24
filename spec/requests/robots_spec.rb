# frozen_string_literal: true

require "rails_helper"

describe "robots.txt" do
  def stub_environment(name)
    allow(Settings.environment).to receive(:name).and_return(name)
  end

  def expect_everything_blocked
    expect(response.body).to include("User-agent: *\nDisallow: /")
    expect(response.body).not_to include("Googlebot")
  end

  context "on the canonical Find host in production" do
    before do
      stub_environment("production")
      host! URI.parse(Settings.find_url).host
      get "/robots.txt"
    end

    it "responds as plain text" do
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/plain")
    end

    it "welcomes the search engines we have approved" do
      expect(response.body).to include("User-agent: Googlebot")
      expect(response.body).to include("User-agent: bingbot")
      expect(response.body).to include("User-agent: DuckDuckBot")
      expect(response.body).to include("User-agent: Applebot")
    end

    it "blocks every crawler it does not name, including AI crawlers" do
      expect(response.body).to include("User-agent: *\nDisallow: /")
    end

    it "does not welcome Applebot-Extended, so Apple's training crawler falls to the block" do
      expect(response.body).not_to include("User-agent: Applebot-Extended")
    end

    it "welcomes link preview bots, so shared course links render a preview card" do
      expect(response.body).to include("User-agent: Twitterbot")
      expect(response.body).to include("User-agent: facebookexternalhit")
      expect(response.body).to include("User-agent: LinkedInBot")
      expect(response.body).to include("User-agent: Slackbot-LinkExpanding")
      expect(response.body).to include("User-agent: Discordbot")
      expect(response.body).to include("User-agent: WhatsApp")
    end

    it "does not welcome meta-externalagent, so Meta's training crawler falls to the block" do
      expect(response.body).not_to include("User-agent: meta-externalagent")
    end

    it "keeps candidate and authentication pages out of search results" do
      expect(response.body).to include("Disallow: /candidate/")
      expect(response.body).to include("Disallow: /auth/")
      expect(response.body).to include("Disallow: /sign-out")
    end

    it "keeps unsubscribe links containing personal tokens out of search results" do
      expect(response.body).to include("Disallow: /email-alerts/")
    end

    it "keeps tracking redirects and internal endpoints out of search results" do
      expect(response.body).to include("Disallow: /track_click")
      expect(response.body).to include("Disallow: /geolocation-suggestions")
      expect(response.body).to include("Disallow: /cycles")
    end

    # A blank line would terminate the group, leaving approved crawlers with
    # no rules at all.
    it "keeps the approved group contiguous, with no blank line before its rules" do
      group = response.body[/^User-agent: Googlebot$.*?^Allow: \/$/m]

      expect(group).to be_present
      expect(group.lines.map(&:chomp)).to all(be_present)
    end

    it "advertises the sitemap on the canonical domain" do
      expect(response.body).to include(
        "Sitemap: https://find-teacher-training-courses.service.gov.uk/sitemap.xml",
      )
    end
  end

  context "on a non-canonical Find host in production" do
    it "blocks everything, so the temporary domain cannot compete with the canonical one" do
      stub_environment("production")
      host! "find-temp.teacherservices.cloud"
      get "/robots.txt"

      expect_everything_blocked
    end
  end

  context "on the Publish host in production" do
    it "blocks everything" do
      stub_environment("production")
      host! URI.parse(Settings.publish_url).host
      get "/robots.txt"

      expect_everything_blocked
    end
  end

  context "on the API host in production" do
    it "blocks everything" do
      stub_environment("production")
      host! URI.parse(Settings.api_url).host
      get "/robots.txt"

      expect_everything_blocked
    end
  end

  context "outside production" do
    %w[staging sandbox qa review development].each do |environment|
      it "blocks everything in #{environment}, even on the Find host" do
        stub_environment(environment)
        host! URI.parse(Settings.find_url).host
        get "/robots.txt"

        expect_everything_blocked
      end
    end
  end
end
