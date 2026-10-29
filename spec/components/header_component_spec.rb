# frozen_string_literal: true

require "rails_helper"

RSpec.describe HeaderComponent, type: :component do
  include Rails.application.routes.url_helpers

  alias_method :component, :page

  it "renders the service name in the service navigation" do
    render_inline(described_class.new(service_name: "Test Service"))

    expect(component.find(".govuk-service-navigation__service-name")).to have_text("Test Service")
  end

  it "links the crown logo to GOV.UK" do
    render_inline(described_class.new(service_name: "Test Service"))

    expect(page).to have_link(nil, href: "https://www.gov.uk")
  end

  it "links the service name to the given service URL" do
    render_inline(described_class.new(service_name: "Test Service", service_url: publish_root_path))

    expect(page).to have_link("Test Service", href: publish_root_path)
  end

  it "renders the environment tag without feedback text when no phase banner text is given" do
    render_inline(described_class.new(service_name: "Support"))

    expect(page).to have_css(".govuk-phase-banner__content__tag", text: Settings.environment.label)
    expect(page.find(".govuk-phase-banner__text").text).to be_blank
    expect(page).to have_no_link("feedback")
  end

  {
    "development" => "grey",
    "production" => "blue",
    "qa" => "orange",
    "review" => "purple",
    "sandbox" => "purple",
    "rollover" => "teal",
    "staging" => "red",
  }.each do |environment, colour|
    it "renders a #{colour} phase banner for the #{environment} environment" do
      allow(Settings.environment).to receive(:name).and_return(environment)
      render_inline(described_class.new(service_name: "Test Service"))

      expect(page).to have_css(".govuk-phase-banner .govuk-tag--#{colour}")
    end
  end

  it "renders phase banner text when given" do
    render_inline(described_class.new(service_name: "Test Service")) do |header|
      header.with_phase_banner_text "This is a test version of Publish for providers and software vendors"
    end

    expect(page).to have_text("This is a test version of Publish for providers and software vendors")
  end

  it "doesn't contain a sign out link if no current user" do
    render_inline(described_class.new(service_name: "test"))

    expect(component).to have_no_text("Sign out")
  end

  it "renders the default account options when a current user is given" do
    user = build(:user, first_name: "Course", last_name: "Anne")

    render_inline(described_class.new(service_name: "test", current_user: user))

    expect(component).to have_text("Course Anne")
    expect(component).to have_text("Sign out")
  end

  it "renders custom account options when given" do
    render_inline(described_class.new(service_name: "test", current_user: build(:user))) do |header|
      header.with_account_options do
        "Support console"
      end
    end

    expect(component).to have_text("Support console")
    expect(component).to have_no_text("Sign out")
  end

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

  context "when provider navigation items are given" do
    let(:recruitment_cycle) { find_or_create(:recruitment_cycle) }
    let(:provider) { create(:provider, recruitment_cycle:) }
    let(:courses_path) { publish_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year) }
    let(:users_path) { publish_provider_users_path(provider_code: provider.provider_code) }
    let(:request_access_path) { request_access_publish_provider_path(provider.provider_code) }

    it "keeps a navigation item active on a child page of its section" do
      with_request_url "#{courses_path}/ABC1", host: "publish.localhost" do
        render_inline(described_class.new(service_name: "Publish", service_url: publish_root_path)) do |header|
          header.with_navigation_item("Courses", courses_path, active_when: [courses_path])
          header.with_navigation_item("Users", users_path, active_when: [users_path, request_access_path])
        end
      end

      courses = page.find(".govuk-service-navigation__item", text: "Courses")
      users = page.find(".govuk-service-navigation__item", text: "Users")

      expect(courses[:class]).to include("govuk-service-navigation__item--active")
      expect(users[:class]).not_to include("govuk-service-navigation__item--active")
    end
  end
end
