require "rails_helper"

RSpec.describe "Publish - Schools changes notification banner", service: :publish, type: :system do
  include DfESignInUserHelper

  let(:frozen_time) { Time.zone.local(2025, 6, 1, 12, 0, 0) }
  let(:schools_page_path) do
    publish_provider_recruitment_cycle_schools_path(provider.provider_code, recruitment_cycle.year)
  end
  let!(:recruitment_cycle) do
    create(:recruitment_cycle, year: 2026, application_start_date: frozen_time + 2.months)
  end
  let(:provider) { create(:provider, provider_name: "Banner Provider", recruitment_cycle:) }
  let!(:site_one)   { create(:site, provider:, added_via: :register_import, location_name: "Added School 1") }
  let!(:site_two)   { create(:site, provider:, added_via: :register_import, location_name: "Added School 2") }
  let!(:site_three) { create(:site, provider:, discarded_via_script: true, location_name: "Removed School 1") }
  let!(:site_four)  { create(:site, provider:, discarded_via_script: true, location_name: "Removed School 2") }
  let!(:site_five)  { create(:site, provider:, added_via: :publish_interface, discarded_via_script: false, location_name: "Not Featured") }
  let(:user) { create(:user, providers: [provider]) }

  before do
    travel_to frozen_time
    sign_in_system_test(user:)
  end

  after { travel_back }

  context "Provider has added and removed schools" do
    scenario "shows banner with both added and removed info" do
      given_provider_has_schools(added: 2, removed: 2)
      when_i_visit_the_publish_schools_page
      then_i_see_the_banner_header("Changes to the schools in your account")
      and_i_see_count_in_banner("We have added 2 schools")
      and_i_see_count_in_banner("We have removed 2 schools")
      and_i_see_added_link
      and_i_see_removed_link
    end
  end

  context "Provider has neither added nor removed schools" do
    before do
      Site.where(provider_id: provider.id).destroy_all
    end

    scenario "shows minimal banner only" do
      given_provider_has_schools(added: 0, removed: 0)
      when_i_visit_the_publish_schools_page
      then_i_see_the_banner_header("The way schools are added to your account has changed.")
      and_i_do_not_see_added_link
      and_i_do_not_see_removed_link
      and_i_do_not_see_text("We have added")
      and_i_do_not_see_text("We have removed")
    end
  end

  context "when provider has added schools only" do
    before do
      Site.where(provider_id: provider.id, discarded_via_script: true).destroy_all
    end

    scenario "shows banner with added info only" do
      given_provider_has_schools(added: 2, removed: 0)
      when_i_visit_the_publish_schools_page
      then_i_see_the_banner_header("Changes to the schools in your account")
      and_i_see_count_in_banner("We have added 2 schools")
      and_i_see_added_link
      and_i_do_not_see_removed_link
      and_i_do_not_see_text("We have removed")
    end
  end

  context "Provider has removed schools only" do
    before do
      Site.where(provider_id: provider.id, added_via: :register_import).destroy_all
    end

    scenario "shows banner with removed info only" do
      given_provider_has_schools(added: 0, removed: 2)
      when_i_visit_the_publish_schools_page
      then_i_see_the_banner_header("Changes to the schools in your account")
      and_i_see_count_in_banner("We have removed 2 schools")
      and_i_see_removed_link
      and_i_do_not_see_added_link
      and_i_do_not_see_text("We have added")
    end
  end

  context "the banner is not shown if recruitment cycle has started" do
    let(:post_rollover_period) { recruitment_cycle.rollover_end + 1.second }

    before do
      travel_to(post_rollover_period)
      sign_in_system_test(user:)
    end

    scenario "the banner is not present" do
      when_i_visit_the_publish_schools_page
      then_i_do_not_see_the_banner
    end
  end

  def given_provider_has_schools(added:, removed:)
    expect(provider.sites.register_import.count).to eq(added)
    expect(Site.where(provider_id: provider.id, discarded_via_script: true).count).to eq(removed)
  end

  def when_i_visit_the_publish_schools_page
    visit schools_page_path
  end

  def then_i_see_the_banner_header(header)
    expect(page).to have_css(".govuk-notification-banner__title", text: header)
  end

  def then_i_do_not_see_the_banner
    expect(page).not_to have_css(".govuk-notification-banner")
  end

  def and_i_see_count_in_banner(content)
    expect(page).to have_css(".govuk-notification-banner__content", text: content)
  end

  def banner_links
    return [] unless page.has_css?(".govuk-notification-banner")

    page.all(".govuk-notification-banner a")
  end

  def find_banner_link_containing(text_snippet, href_snippet)
    banner_links.find do |link|
      link.text.include?(text_snippet) && link[:href].include?(href_snippet)
    end
  end

  def and_i_see_added_link
    link = find_banner_link_containing("added", "added-schools")

    expect(link).to be_present,
                    "Expected to find 'added' link with href containing 'added-schools'. " \
                    "Found links: #{banner_links.map { |l| "'#{l.text}' => #{l[:href]}" }.join(', ')}"
  end

  def and_i_see_removed_link
    link = find_banner_link_containing("removed", "removed-schools")

    expect(link).to be_present,
                    "Expected to find 'removed' link with href containing 'removed-schools'. " \
                    "Found links: #{banner_links.map { |l| "'#{l.text}' => #{l[:href]}" }.join(', ')}"
  end

  def and_i_do_not_see_added_link
    link = find_banner_link_containing("added", "added-schools")

    expect(link).to be_nil,
                    "Expected NOT to find 'added' link, but found: '#{link&.text}' => #{link&.[](:href)}"
  end

  def and_i_do_not_see_removed_link
    link = find_banner_link_containing("removed", "removed-schools")

    expect(link).to be_nil,
                    "Expected NOT to find 'removed' link, but found: '#{link&.text}' => #{link&.[](:href)}"
  end

  def and_i_do_not_see_text(text)
    expect(page).not_to have_text(text)
  end
end
