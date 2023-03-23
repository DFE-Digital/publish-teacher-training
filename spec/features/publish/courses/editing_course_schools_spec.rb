# frozen_string_literal: true

require 'rails_helper'

feature 'Editing course schools', { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    when_i_visit_the_publish_course_school_edit_page
  end

  scenario 'i can update the course schools' do
    then_i_should_see_a_list_of_schools
    when_i_update_the_course_schools
    and_i_submit
    then_i_should_see_a_success_message
    and_the_course_schools_are_updated
  end

  scenario 'updating with invalid data' do
    and_i_submit
    then_i_should_see_an_error_message
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(
      user: create(
        :user,
        providers: [
          build(
            :provider,
            sites: [
              build(:site, location_name: 'Site 1'),
              build(:site, location_name: 'Site 2')
            ]
          )
        ]
      )
    )
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists(sites: [])
  end

  def when_i_visit_the_publish_course_school_edit_page
    publish_course_school_edit_page.load(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      course_code: course.course_code
    )
  end

  def then_i_should_see_a_list_of_schools
    expect(publish_course_school_edit_page.vacancy_names).to contain_exactly('Site 1', 'Site 2')
  end

  def when_i_update_the_course_schools
    publish_course_school_edit_page.vacancies.find do |el|
      el.find('.govuk-label').text == 'Site 1'
    end.check
  end

  def and_i_submit
    publish_course_school_edit_page.submit.click
  end

  def then_i_should_see_a_success_message
    expect(page).to have_content(I18n.t('success.saved', value: 'School'))
  end

  def and_the_course_schools_are_updated
    expect(course.reload.sites.map(&:location_name)).to contain_exactly('Site 1')
  end

  def then_i_should_see_an_error_message
    expect(publish_course_school_edit_page).to have_content(
      I18n.t('activemodel.errors.models.publish/course_school_form.attributes.site_ids.no_schools')
    )
  end

  def provider
    @current_user.providers.first
  end
end
