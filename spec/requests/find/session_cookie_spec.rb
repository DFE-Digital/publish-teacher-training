# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Find session cookie", service: :find, type: :request do
  around do |example|
    allow_forgery_protection = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    example.run
  ensure
    ActionController::Base.allow_forgery_protection = allow_forgery_protection
  end

  it "persists for 2 weeks" do
    get find_results_path

    expires = cookies.get_cookie(Settings.cookies.session.name).expires

    expect(expires).to be_within(1.minute).of(2.weeks.from_now)
  end

  it "is not sent with the publicly cacheable sitemap" do
    get find_results_path
    get find_sitemap_path(format: :xml)

    expect(response.headers["Cache-Control"]).to include("public")
    expect(response.headers["Set-Cookie"]).to be_nil
  end
end
