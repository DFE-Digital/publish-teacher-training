# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Display rollover soon banner in publish" do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario "when rollover soon banner feature flag is enabled the banner is visible" do
    and_the_rollover_soon_banner_feature_flag_is_enabled
    when_i_visit_the_courses_page
    then_i_see_the_rollover_soon_banner
  end

  scenario "when rollover soon banner feature flag is disabled the banner is not visible" do
    and_the_rollover_soon_banner_feature_flag_is_disabled
    when_i_visit_the_courses_page
    then_i_do_not_see_the_rollover_soon_banner
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(
      user: create(:user, providers: [create(:provider, sites: [build(:site)])]),
    )
  end

  def when_i_visit_the_courses_page
    publish_provider_courses_index_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year,
    )
  end

  def provider
    @current_user.providers.first
  end

  def and_the_rollover_soon_banner_feature_flag_is_enabled
    FeatureFlag.activate(:publish_rollover_soon_banner)
  end

  def and_the_rollover_soon_banner_feature_flag_is_disabled
    FeatureFlag.deactivate(:publish_rollover_soon_banner)
  end

  def then_i_see_the_rollover_soon_banner
    expect(page).to have_content("your courses will be ready to be rolled over to the")
    expect(page).to have_content("We will email you when you need to sign in to check and publish, or delete, your courses.")
  end

  def then_i_do_not_see_the_rollover_soon_banner
    expect(page).not_to have_content("your courses will be ready to be rolled over to the")
    expect(page).not_to have_content("We will email you when you need to sign in to check and publish, or delete, your courses.")
  end
end
