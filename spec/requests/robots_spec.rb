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

  it "responds as plain text" do
    host! URI.parse(Settings.find_url).host
    get "/robots.txt"

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("text/plain")
  end

  it "blocks everything on the Find host" do
    stub_environment("production")
    host! URI.parse(Settings.find_url).host
    get "/robots.txt"

    expect_everything_blocked
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
