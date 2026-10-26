# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publish session cookie", service: :publish, type: :request do
  it "lasts only for the browser session" do
    get "/sign-in"

    session_cookie = cookies.get_cookie(Settings.cookies.session.name)

    expect(session_cookie).to be_present
    expect(session_cookie.expires).to be_nil
  end
end
