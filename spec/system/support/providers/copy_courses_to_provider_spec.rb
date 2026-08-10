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
  let(:shared_school) { create(:gias_school, :open, name: "Shared Placement School") }

  # A provider school and the legacy site it was dual-written with, joined by
  # the uuid the two share.
  def link_school(provider, gias_school, site_code)
    site = create(:site, provider:, urn: gias_school.urn, code: site_code)
    create(:provider_school, provider:, gias_school:, site_code:, uuid: site.uuid)
  end

  before do
    sign_in_system_test(user:)

    # The first course has a placement at a school the target provider already
    # has, so ticking the checkbox should carry that placement across.
    source_school = link_school(source_provider, shared_school, "A")
    link_school(target_provider, shared_school, "Z")
    create(:course_school, course: courses.first, provider_school: source_school, gias_school: shared_school)
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

    click_on courses.first.name_and_code
    click_on "Basic details"
    expect(page).to have_content("Shared Placement School")
  end
end
