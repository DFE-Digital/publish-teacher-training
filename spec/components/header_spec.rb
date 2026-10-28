# frozen_string_literal: true

require "rails_helper"

describe Header do
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

  it "links the service name to the Publish homepage" do
    render_inline(described_class.new(service_name: "Test Service"))

    expect(page).to have_link("Test Service", href: publish_root_path)
  end

  it "renders the environment tag without feedback text" do
    render_inline(described_class.new(service_name: "Test Service"))

    expect(page).to have_css(".govuk-phase-banner__content__tag", text: Settings.environment.label)
    expect(page).to have_no_link("feedback")
    expect(page).to have_no_text("This is a new service")
  end

  {
    "development" => "grey",
    "qa" => "orange",
    "review" => "purple",
    "sandbox" => "purple",
    "rollover" => "teal",
    "staging" => "red",
    "unknown-environment" => "yellow",
  }.each do |environment, colour|
    it "renders a #{colour} phase banner for the #{environment} environment" do
      allow(Settings.environment).to receive(:name).and_return(environment)
      render_inline(described_class.new(service_name: "Test Service"))

      expect(page).to have_css(".govuk-phase-banner .govuk-tag--#{colour}")
    end
  end

  it "renders sandbox message text in sandbox mode" do
    allow(Settings.environment).to receive(:name).and_return("sandbox")
    render_inline(described_class.new(service_name: "Test Service"))

    expect(page).to have_text("This is a test version of Publish for providers and software vendors")
  end

  it "doesn't contain a sign out link if no current user" do
    render_inline(described_class.new(service_name: "test"))
    expect(component).to have_no_text("Sign out")
  end

  context "for an admin user" do
    it "renders a sign out link" do
      render_inline(
        described_class.new(
          service_name: "test",
          current_user: build(:user, :admin),
        ),
      )

      expect(component).to have_text("Sign out")
    end
  end

  context "for a non-admin user" do
    it "links to the notifications section if associated_with_accredited_provider" do
      user = build(:user)
      allow(user).to receive(:associated_with_accredited_provider?).and_return true

      render_inline(described_class.new(service_name: "Test Service", current_user: user))

      expect(page).to have_link("Notifications", href: publish_notifications_path)
    end
  end

  context "when provider navigation is shown" do
    let(:recruitment_cycle) { find_or_create(:recruitment_cycle) }
    let(:provider) { create(:provider, recruitment_cycle:) }
    let(:courses_path) { publish_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year) }
    let(:users_path) { publish_provider_users_path(provider_code: provider.provider_code) }
    let(:request_access_path) { request_access_publish_provider_path(provider.provider_code) }

    it "keeps a navigation item active on a child page of its section" do
      with_request_url "#{courses_path}/ABC1", host: "publish.localhost" do
        render_inline(described_class.new(service_name: "Publish", provider:))
      end

      courses = page.find(".govuk-service-navigation__item", text: "Courses")
      users = page.find(".govuk-service-navigation__item", text: "Users")

      expect(courses[:class]).to include("govuk-service-navigation__item--active")
      expect(users[:class]).not_to include("govuk-service-navigation__item--active")
    end

    it "includes the request access path in the Users active_when" do
      header = described_class.new(service_name: "Publish", provider:)
      users_item = { name: "Users", url: users_path, additional_url: request_access_path }

      expect(header.active_when_for(users_item)).to eq([users_path, request_access_path])
    end
  end
end
