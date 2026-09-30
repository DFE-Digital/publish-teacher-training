# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Find session cookie", service: :find, type: :request do
  around do |example|
    ActionController::Base.allow_forgery_protection = true
    example.run
  ensure
    ActionController::Base.allow_forgery_protection = false
  end

  it "persists for 2 weeks" do
    get find_results_path

    expires = session_cookie_header[/expires=([^;]+)/i, 1]

    expect(expires && Time.httpdate(expires)).to be_within(1.minute).of(2.weeks.from_now)
  end

  def session_cookie_header
    response.headers["Set-Cookie"].to_s.split("\n").find { it.start_with?("#{Settings.cookies.session.name}=") }.to_s
  end
end
