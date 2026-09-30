# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publish session cookie", service: :publish, type: :request do
  it "lasts only for the browser session" do
    get "/sign-in"

    expect(session_cookie_header).to start_with("#{Settings.cookies.session.name}=")
    expect(session_cookie_header).not_to match(/expires=/i)
  end

  def session_cookie_header
    response.headers["Set-Cookie"].to_s.split("\n").find { it.start_with?("#{Settings.cookies.session.name}=") }.to_s
  end
end
