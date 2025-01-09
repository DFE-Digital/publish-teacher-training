# frozen_string_literal: true

require 'rails_helper'

feature 'Viewing courses as an ratifying provider', { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_an_accredited_provider_user
    and_some_courses_exist_with_one_i_ratify
    when_i_visit_the_publish_training_provider_index_page
  end

  scenario 'i can see who lists me as their accredited partner' do
    then_i_should_see_a_list_of_training_providers
    and_i_should_see_a_count_of_the_courses_i_ratify
  end

  scenario 'i can see which courses for which i am the ratifying provider' do
    and_i_click_on_a_training_provider
    then_i_see_the_courses_i_ratify
  end

  def given_i_am_authenticated_as_an_accredited_provider_user
    given_i_am_authenticated(user: create(:user, providers: [create(:provider, :accredited_provider)]))
  end

  def and_some_courses_exist_with_one_i_ratify
    given_a_course_exists(
      enrichments: [build(:course_enrichment, :published)],
      provider: create(:provider),
      accrediting_provider:
    )

    create(:course, enrichments: [build(:course_enrichment, :published)], provider: create(:provider))
  end

  def when_i_visit_the_publish_training_provider_index_page
    publish_training_provider_index_page.load(
      provider_code: accrediting_provider.provider_code, recruitment_cycle_year: accrediting_provider.recruitment_cycle_year
    )
  end

  def then_i_should_see_a_list_of_training_providers
    expect(publish_training_provider_index_page.training_provider_rows.size).to eq(1)

    expect(publish_training_provider_index_page.training_provider_rows.first.name).to have_text(training_provider.provider_name)
  end

  def and_i_should_see_a_count_of_the_courses_i_ratify
    expect(publish_training_provider_index_page.training_provider_rows.first.course_count).to have_text('1')
  end

  def and_i_click_on_a_training_provider
    publish_training_provider_index_page.training_provider_rows.first.name.click
  end

  def then_i_see_the_courses_i_ratify
    expect(publish_training_providers_course_index_page).to be_displayed
    expect(publish_training_providers_course_index_page.courses.size).to eq(1)
    expect(publish_training_providers_course_index_page.courses.first.name).to have_text(course.name)
  end

  def accrediting_provider
    @current_user.providers.first
  end

  def training_provider
    @training_provider ||= course.provider
  end
end
