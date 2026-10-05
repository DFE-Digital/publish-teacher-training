# frozen_string_literal: true

require "rails_helper"

RSpec.describe HeaderComponent, type: :component do
  it "keeps a navigation item active on a child page of its section" do
    year = Find::CycleTimetable.current_year

    with_request_url "/support/#{year}/providers/1/schools", host: "publish.localhost" do
      render_inline(described_class.new(service_name: "Support")) do |header|
        header.with_navigation_item("Providers", "/support/#{year}/providers", active_when: "/support/#{year}/providers")
        header.with_navigation_item("Users", "/support/#{year}/users", active_when: "/support/#{year}/users")
      end
    end

    providers = page.find(".govuk-service-navigation__item", text: "Providers")
    users = page.find(".govuk-service-navigation__item", text: "Users")

    expect(providers[:class]).to include("govuk-service-navigation__item--active")
    expect(users[:class]).not_to include("govuk-service-navigation__item--active")
  end

  it "does not mark a navigation item active on a child page when no section is given" do
    year = Find::CycleTimetable.current_year

    with_request_url "/support/#{year}/providers/1", host: "publish.localhost" do
      render_inline(described_class.new(service_name: "Support")) do |header|
        header.with_navigation_item("Providers", "/support/#{year}/providers")
      end
    end

    providers = page.find(".govuk-service-navigation__item", text: "Providers")

    expect(providers[:class]).not_to include("govuk-service-navigation__item--active")
  end

  it "renders the environment tag without feedback text when no phase banner text is given" do
    render_inline(described_class.new(service_name: "Support"))

    expect(page).to have_css(".govuk-phase-banner__content__tag", text: "Test")
    expect(page).to have_no_css(".govuk-phase-banner__text")
    expect(page).to have_no_link("feedback")
  end
end
