# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Display rollover notification banner in publish" do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario "when rollover banner feature flag is enabled the banner is visible" do
    and_the_rollover_banner_feature_flag_is_enabled
    when_i_visit_the_courses_page
    then_i_see_the_rollover_notification_banner
  end

  scenario "when rollover banner feature flag is disabled the banner is not visible" do
    and_the_rollover_banner_feature_flag_is_disabled
    when_i_visit_the_courses_page
    then_i_do_not_see_the_rollover_notification_banner
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

  def and_the_rollover_banner_feature_flag_is_enabled
    FeatureFlag.activate(:publish_rollover_banner)
  end

  def and_the_rollover_banner_feature_flag_is_disabled
    FeatureFlag.deactivate(:publish_rollover_banner)
  end

  def then_i_see_the_rollover_notification_banner
    expect(page).to have_content("Action required by 28 September: check and schedule your courses")
    expect(page).to have_content("Courses for the 2026 to 2027 recruitment cycle will be published on Find teacher training courses on 29 September. Before this, you need to check and schedule your rolled over courses. If you do not schedule your courses, candidates will not be able to see them when Find opens.")
    expect(page).to have_link("Find teacher training courses", href: find_root_url)
    expect(page).to have_link(
      "guidance on rolling over courses to a new recruitment cycle",
      href: roll_over_courses_to_a_new_recruitment_cycle_path,
    )
  end

  def then_i_do_not_see_the_rollover_notification_banner
    expect(page).not_to have_content("Action required by 28 September: check and schedule your courses")
    expect(page).not_to have_content("Courses for the 2026 to 2027 recruitment cycle will be published on Find teacher training courses on 29 September.")
    expect(page).not_to have_link(
      "guidance on rolling over courses to a new recruitment cycle",
      href: roll_over_courses_to_a_new_recruitment_cycle_path,
    )
  end
end
