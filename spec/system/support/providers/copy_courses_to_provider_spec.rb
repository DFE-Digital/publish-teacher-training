# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Support copies courses between providers", service: :publish do
  include DfESignInUserHelper

  let(:courses) do
    [
      create(:course, :unpublished, :with_full_time_sites),
      create(:course, :published, :with_full_time_sites),
      create(:course, :withdrawn, :with_full_time_sites),
    ]
  end
  let!(:source_provider) { create(:provider, provider_name: "Source Provider", courses:) }
  let!(:target_provider) { create(:provider, provider_name: "Target Provider") }
  let(:user) { create(:user, :admin) }

  before do
    sign_in_system_test(user:)
  end

  it "copies courses from one provider to another using the autocomplete", :js do
    visit "/support"
    click_on "Target Provider"
    click_on "Courses"
    click_on "Copy Courses"

    fill_in "provider", with: source_provider.provider_code
    expect(page).to have_css("#provider__listbox")
    page.find("#provider__listbox li", text: source_provider.provider_name).click

    check "Copy placement schools?"
    click_on "Copy courses"
    click_on "Courses"

    courses.map(&:name).each do |course_name|
      expect(page).to have_content(course_name)
    end
  end
end
