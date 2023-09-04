# frozen_string_literal: true

require 'rails_helper'

feature 'Add course button', { can_edit_current_and_next_cycles: true } do
  scenario 'with study sites on the provider' do
    given_i_am_authenticated_as_a_provider_user_with_study_sites
    when_i_visit_the_courses_page
    then_i_should_see_the_add_course_button
  end

  def then_i_should_see_the_add_course_button
    expect(page).to have_link('Add course')
  end

  def given_i_am_authenticated_as_a_provider_user_with_study_sites
    given_i_am_authenticated(
      user: create(
        :user,
        providers: [
          create(:provider, :accredited_provider, sites: [build(:site)], study_sites: [build(:site, :study_site)], courses: [build(:course)])
        ]
      )
    )
  end

  def when_i_visit_the_courses_page
    publish_provider_courses_index_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year
    )
  end

  def provider
    @current_user.providers.first
  end
end
