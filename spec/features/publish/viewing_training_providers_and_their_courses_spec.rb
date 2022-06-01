# frozen_string_literal: true

require "rails_helper"

feature "Viewing courses as an accredited body" do
  before do
    given_the_can_edit_current_and_next_cycles_feature_flag_is_disabled
    given_i_am_authenticated_as_an_accredited_body_user
    and_some_courses_exist_with_one_i_accredit
    when_i_visit_the_training_providers_page
  end

  scenario "i can see who lists me as their accredited body" do
    then_i_should_see_a_list_of_training_providers
    and_i_should_see_a_count_of_the_courses_i_accredit
  end

  scenario "i can see which courses i am the accredited body for" do
    and_i_click_on_a_training_provider
    then_i_see_the_courses_i_accredit_for
  end

  def given_i_am_authenticated_as_an_accredited_body_user
    given_i_am_authenticated(user: create(:user, providers: [create(:provider, :accredited_body)]))
  end

  def and_some_courses_exist_with_one_i_accredit
    given_a_course_exists(
      enrichments: [build(:course_enrichment, :published)],
      provider: create(:provider),
      accrediting_provider: accrediting_provider,
    )

    create(:course, enrichments: [build(:course_enrichment, :published)], provider: create(:provider))
  end

  def when_i_visit_the_training_providers_page
    training_providers_page.load(
      provider_code: accrediting_provider.provider_code, recruitment_cycle_year: accrediting_provider.recruitment_cycle_year,
    )
  end

  def then_i_should_see_a_list_of_training_providers
    expect(training_providers_page.training_provider_rows.size).to eq(1)

    expect(training_providers_page.training_provider_rows.first.name).to have_text(training_provider.provider_name)
  end

  def and_i_should_see_a_count_of_the_courses_i_accredit
    expect(training_providers_page.training_provider_rows.first.course_count).to have_text("1")
  end

  def and_i_click_on_a_training_provider
    training_providers_page.training_provider_rows.first.name.click
  end

  def then_i_see_the_courses_i_accredit_for
    expect(training_provider_courses_page).to be_displayed
    expect(training_provider_courses_page.courses.size).to eq(1)
    expect(training_provider_courses_page.courses.first.name).to have_text(course.name)
  end

  def accrediting_provider
    @current_user.providers.first
  end

  def training_provider
    @training_provider ||= course.provider
  end
end
