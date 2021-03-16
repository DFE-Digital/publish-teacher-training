require "rails_helper"

RSpec.feature "viewing dashboard" do
  before do
    @original_gias_dashboard_setting = Settings.features.gias_dashboard
  end

  after do
    if Settings.features.gias_dashboard != @original_gias_dashboard_setting
      Settings.features.gias_dashboard = @original_gias_dashboard_setting
      Rails.application.reload_routes!
    end
  end

  scenario "feature not enabled" do
    given_the_gias_dashboard_feature_is_disabled

    # How to express this as a `when ... then`?
    expect {
      visit "/gias"
    }.to raise_error(ActionController::RoutingError)
  end

  scenario "features enabled but user not authenticated" do
    given_the_gias_dashboard_feature_is_enabled

    when_i_visit_the_gias_dashboard

    then_i_should_be_on_the_sign_in_page
  end

  def given_the_gias_dashboard_feature_is_enabled
    Settings.features.gias_dashboard = true
    Rails.application.reload_routes!
  end

  def given_the_gias_dashboard_feature_is_disabled
    Settings.features.gias_dashboard = false
    Rails.application.reload_routes!
  end

  def when_i_visit_the_gias_dashboard
    visit "/gias"
  end

  def then_i_should_be_on_the_sign_in_page
    expect(page.current_path).to eq "/sign-in"
  end
end
