# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Publish - Courses page", service: :publish do
  include DfESignInUserHelper

  let(:provider) { create(:provider, provider_name: "System Provider") }
  let(:course) { create(:course, provider:, name: "System Course") }
  let(:user) { create(:user, providers: [provider]) }

  before do
    sign_in_system_test(user:)
    course
  end

  it "shows the publish courses page" do
    visit "/publish/organisations"
    expect(page).to have_content("Sign out")
    expect(page).to have_content(course.name)
  end
end
