# frozen_string_literal: true

require 'rails_helper'

feature 'course confirmation', { can_edit_current_and_next_cycles: false } do
  context 'lead school' do
    before do
      given_i_am_authenticated_as_a_provider_user
      when_i_visit_the_publish_course_confirmation_page
    end

    scenario 'creating course' do
      and_i_click_continue

      then_i_am_met_with_the_publish_provider_courses_index_page
    end

    scenario 'it displays the correct information' do
      then_it_displays_correctly
    end

    scenario 'changing subject to modern languages' do
      when_i_click_change_subject
      and_i_select_modern_languages_and_maths
      and_i_click_continue
      and_i_select_some_languages
      and_i_click_continue
      then_subjects_list_correctly_on_confirmation_page
    end

    scenario 'changing funding_type to fee' do
      when_i_click_change_funding_type
      and_i_select_funding_type(:fee)
      and_i_click_continue
      and_i_should_see_the_title_as('Student visas')
      and_i_click_continue
      then_i_should_be_on_the_confirmation_page
    end

    scenario 'changing funding_type to apprenticeship' do
      when_i_click_change_funding_type
      and_i_select_funding_type(:apprenticeship)
      and_i_click_continue
      and_i_should_see_the_title_as('Skilled Worker visas')
      and_i_click_continue
      then_i_should_be_on_the_confirmation_page
    end

    scenario 'changing funding_type to salary' do
      when_i_click_change_funding_type
      and_i_select_funding_type(:salary)
      and_i_click_continue
      and_i_should_see_the_title_as('Skilled Worker visas')
      and_i_click_continue
      then_i_should_be_on_the_confirmation_page
    end
  end

  context 'accredited body' do
    before do
      given_i_am_authenticated_as_a_provider_user(:accredited_body)
      when_i_visit_the_publish_course_confirmation_page
    end

    scenario 'changing to yes' do
      when_i_click_change_apprenticeship
      and_i_select(:yes)
      and_i_click_continue
      and_i_should_see_the_title_as('Skilled Worker visas')
      and_i_click_continue
      then_i_should_be_on_the_confirmation_page
    end

    scenario 'changing to no' do
      when_i_click_change_apprenticeship
      and_i_select(:no)
      and_i_click_continue
      and_i_should_see_the_title_as('Student visas')
      and_i_click_continue
      then_i_should_be_on_the_confirmation_page
    end
  end

  private

  def when_i_click_change_subject
    publish_course_confirmation_page.details.subjects.change_link.click
  end

  def when_i_click_change_funding_type
    publish_course_confirmation_page.details.funding_type.change_link.click
  end

  def when_i_click_change_apprenticeship
    publish_course_confirmation_page.details.apprenticeship.change_link.click
  end

  def and_i_select_funding_type(funding_type)
    publish_courses_new_funding_type_page.funding_type_fields.send(funding_type).click
  end

  def and_i_select(choice)
    publish_courses_new_apprenticeship_page.send(choice).click
  end

  def and_i_select_modern_languages_and_maths
    publish_courses_new_subjects_page.master_subject_fields.select('Modern Languages').click
    publish_courses_new_subjects_page.subordinate_subjects_fields.select('Mathematics').click
  end

  def and_i_should_see_the_title_as(title)
    expect(page.title).to have_text(title)
  end

  def then_i_should_be_on_the_confirmation_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/confirmation", ignore_query: true)
  end

  def and_i_select_some_languages
    publish_courses_new_modern_languages_page.language_checkbox('German').click
    publish_courses_new_modern_languages_page.language_checkbox('Italian').click
  end

  def and_i_click_continue
    page.find('[data-qa="course__save"]').click
  end

  def then_subjects_list_correctly_on_confirmation_page
    expect(publish_course_confirmation_page.details.subjects.value).to have_content('Modern LanguagesGermanItalianMathematics')
  end

  def given_i_am_authenticated_as_a_provider_user(provider_trait = nil)
    providers = if provider_trait.present?
                  [build(:provider, provider_trait, sites: [build(:site)])]
                else
                  [build(:provider, sites: [build(:site)])]
                end

    @user = create(:user, providers:)
    @user.providers.first.courses << create(:course, :with_accrediting_provider)
    given_i_am_authenticated(user: @user)
  end

  def when_i_visit_the_publish_course_confirmation_page
    publish_course_confirmation_page.load(
      provider_code: provider.provider_code,
      recruitment_cycle_year: Settings.current_recruitment_cycle_year,
      query: confirmation_params(provider)
    )
  end

  def provider
    @provider ||= @user.providers.first
  end

  def site
    @site ||= provider.sites.first
  end

  def then_i_am_met_with_the_publish_provider_courses_index_page
    expect(publish_provider_courses_index_page).to be_displayed
    expect(publish_provider_courses_index_page.success_summary).to have_content('Your course has been created')
  end

  def then_it_displays_correctly
    expect(page.title).to start_with('Check your answers')

    expect(publish_course_confirmation_page.title).to have_content('Check your answers')
    expect(publish_course_confirmation_page.details.level.value.text).to eq('Secondary')
    expect(publish_course_confirmation_page.details.is_send.value.text).to eq('No')
    expect(publish_course_confirmation_page.details.subjects.value.text).to include('Psychology')
    expect(publish_course_confirmation_page.details.age_range.value.text).to eq('14 to 19')
    expect(publish_course_confirmation_page.details.study_mode.value.text).to eq('Full time or part time')
    expect(publish_course_confirmation_page.details.locations.value.text).to have_content(site.location_name)
    expect(publish_course_confirmation_page.details.applications_open.value.text).to eq("12 October #{Settings.current_recruitment_cycle_year.to_i - 1}")
    expect(publish_course_confirmation_page.details.start_date.value.text).to eq("October #{Settings.current_recruitment_cycle_year.to_i - 1}")
    expect(publish_course_confirmation_page.details.name.value.text).to eq('Psychology')
  end
end
