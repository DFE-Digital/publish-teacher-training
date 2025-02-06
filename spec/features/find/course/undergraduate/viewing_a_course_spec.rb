# frozen_string_literal: true

require 'rails_helper'

feature 'Viewing an undergraduate course' do
  include Rails.application.routes.url_helpers

  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
  end

  after do
    Timecop.return
  end

  scenario 'user visits get into teaching advice page' do
    given_there_is_a_findable_undergraduate_course
    when_i_visit_the_course_page
    and_i_click_to_contact_get_into_teaching
    then_i_am_redirected_to_the_git_help_and_support_page
  end

  def given_there_is_a_findable_undergraduate_course
    user = create(:user, providers: [build(:provider, provider_type: 'lead_school', sites: [build(:site), build(:site)], study_sites: [build(:site, :study_site), build(:site, :study_site)])])
    provider = user.providers.first
    create(:provider, :accredited_provider, provider_code: '1BK')
    accredited_provider = create(:provider, :accredited_provider, provider_code: '1BJ')
    provider.accrediting_provider_enrichments = []
    provider.accrediting_provider_enrichments << AccreditingProviderEnrichment.new(
      {
        UcasProviderCode: accredited_provider.provider_code,
        Description: 'description'
      }
    )
    @course = create(:course, :published_teacher_degree_apprenticeship, :secondary, provider:, name: 'Biology', subjects: [find_or_create(:secondary_subject, :biology)])
  end

  def when_i_visit_the_course_page
    visit find_course_path(
      provider_code: @course.provider.provider_code,
      course_code: @course.course_code
    )
  end

  def and_i_click_to_contact_get_into_teaching
    expect(page).to have_content('Support and advice')
    expect(page).to have_content('You can contact Get Into Teaching for free support')
    click_link_or_button('contact Get Into Teaching')
  end

  def then_i_am_redirected_to_the_git_help_and_support_page
    expect(page.current_url).to eq(
      'https://getintoteaching.education.gov.uk/help-and-support'
    )
  end
end
