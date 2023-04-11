# frozen_string_literal: true

require 'rails_helper'

feature 'Course show', { can_edit_current_and_next_cycles: false } do
  context 'bursaries and scholarships is announced' do
    before do
      FeatureFlag.activate(:bursaries_and_scholarships_announced)
    end

    scenario 'i can view the course basic details' do
      given_i_am_authenticated(user: user_with_fee_based_course)
      when_i_visit_the_publish_course_preview_page
      then_i_see_the_course_preview_details
      and_i_see_financial_support
    end
  end

  context 'with empty sections' do
    before do
      allow(Settings.features).to receive(:course_preview_missing_information).and_return(true)
    end

    scenario 'blank training with disabilities and other needs' do
      given_i_am_authenticated(user: user_with_no_course_enrichments)
      when_i_visit_the_publish_course_preview_page
      and_i_click_link('Enter details about training with disabilities and other needs')
      then_i_should_be_on_about_your_organisation_page
      and_i_click_link('Back')
      then_i_should_be_back_on_the_preview_page
      and_i_click_link('Enter details about training with disabilities and other needs')
      and_i_submit_a_valid_about_your_organisation
      then_i_should_be_back_on_the_preview_page
      then_i_should_see_the_updated_content('test training with disabilities')
    end

    scenario 'blank course summary' do
      given_i_am_authenticated(user: user_with_no_course_enrichments)
      when_i_visit_the_publish_course_preview_page
      and_i_click_link('Enter course summary')
      and_i_click_link('Back')
      and_i_click_link('Enter course summary')
      and_i_submit_a_valid_form
      and_i_see_the_correct_banner
      and_i_see_the_new_course_text
      then_i_should_be_back_on_the_preview_page
    end

    scenario 'blank degree requirements' do
      given_i_am_authenticated(user: user_with_no_course_enrichments)
      when_i_visit_the_publish_course_preview_page
      and_i_click_link('Enter degree requirements')
      and_i_am_on_the_degree_requirements_page
      and_i_click_link('Back')
      then_i_should_be_back_on_the_preview_page
      and_i_click_link('Enter degree requirements')
      and_i_submit_and_continue_through_the_two_forms
      then_i_should_see_the_updated_content('An undergraduate degree, or equivalent.')
    end

    scenario 'blank gcse requirements' do
      given_i_am_authenticated(user: user_with_no_course_enrichments)
      when_i_visit_the_publish_course_preview_page
      and_i_click_link('Enter GCSE and equivalency test requirements')
      and_i_click_link('Back')
      and_i_click_link('Enter GCSE and equivalency test requirements')
      and_i_choose_no_and_submit
      and_i_see_the_correct_banner
      and_i_see_the_correct_gcse_text
      then_i_should_be_back_on_the_preview_page
    end

    scenario 'blank school placements' do
      given_i_am_authenticated(user: user_with_no_course_enrichments)
      when_i_visit_the_publish_course_preview_page
      and_i_click_link('Enter details about school placements')
      and_i_click_link('Back')
      and_i_click_link('Enter details about school placements')
      and_i_submit_a_valid_form
      and_i_see_the_correct_banner
      then_i_should_be_back_on_the_preview_page
    end

    scenario 'blank fees uk eu' do
      given_i_am_authenticated(user: user_with_no_course_enrichments)
      when_i_visit_the_publish_course_preview_page
      and_i_click_link('Enter details about fees and financial support')
      and_i_click_link('Back')
      and_i_click_link('Enter details about fees and financial support')
      and_i_submit_a_valid_course_fees
      and_i_see_the_correct_banner
      and_i_see_the_the_course_fee
      then_i_should_be_back_on_the_preview_page
    end
  end

  context 'bursaries and scholarships is not announced' do
    scenario 'i can view the course basic details' do
      given_i_am_authenticated(user: user_with_fee_based_course)
      when_i_visit_the_publish_course_preview_page
      then_i_see_the_course_preview_details
      and_i_do_not_see_financial_support
    end
  end

  context 'contact details for London School of Jewish Studies and the course code is X104' do
    scenario 'renders the custom address requested via zendesk' do
      given_i_am_authenticated(
        user: user_with_custom_address_requested_via_zendesk
      )
      when_i_visit_the_publish_course_preview_page
      then_i_see_custom_address
    end
  end

  private

  def then_i_see_custom_address
    expect(publish_course_preview_page).to have_content 'LSJS'
    expect(publish_course_preview_page).to have_content '44A Albert Road'
    expect(publish_course_preview_page).to have_content 'London'
    expect(publish_course_preview_page).to have_content 'NW4 2SJ'
  end

  def then_i_see_the_course_preview_details
    expect(publish_course_preview_page.title).to have_content(
      "#{course.name} (#{course.course_code})"
    )

    expect(publish_course_preview_page.sub_title).to have_content(
      provider.provider_name
    )

    expect(publish_course_preview_page.accredited_body).to have_content(
      accrediting_provider.provider_name
    )

    expect(publish_course_preview_page.description).to have_content(
      course.description
    )

    expect(publish_course_preview_page.qualifications).to have_content(
      'PGCE with QTS'
    )

    expect(publish_course_preview_page.age_range_in_years).to have_content(
      '11 to 18'
    )

    expect(publish_course_preview_page.funding_option).to have_content(
      decorated_course.funding_option
    )

    expect(publish_course_preview_page.length).to have_content(
      'Up to 2 years - full time'
    )

    expect(publish_course_preview_page.applications_open_from).to have_content(
      course.applications_open_from.strftime('%-d %B %Y')
    )

    expect(publish_course_preview_page.start_date).to have_content(
      "September #{recruitment_cycle.year}"
    )

    expect(publish_course_preview_page.provider_website).to have_content(
      provider.website
    )

    expect(publish_course_preview_page).not_to have_vacancies

    expect(publish_course_preview_page.about_course).to have_content(
      decorated_course.about_course
    )

    expect(publish_course_preview_page.interview_process).to have_content(
      decorated_course.interview_process
    )

    expect(publish_course_preview_page.school_placements).to have_content(
      decorated_course.how_school_placements_work
    )

    expect(publish_course_preview_page).to have_content(
      "The course fees for #{recruitment_cycle.year} to #{recruitment_cycle.year.to_i + 1} are as follows"
    )

    expect(publish_course_preview_page.uk_fees).to have_content(
      '£9,250'
    )

    expect(publish_course_preview_page.international_fees).to have_content(
      '£14,000'
    )

    expect(publish_course_preview_page.fee_details).to have_content(
      decorated_course.fee_details
    )

    expect(publish_course_preview_page).not_to have_salary_details

    expect(publish_course_preview_page.financial_support_details).to have_content(
      'Financial support from the training provider'
    )

    expect(publish_course_preview_page.personal_qualities).to have_content(
      decorated_course.personal_qualities
    )

    expect(publish_course_preview_page.other_requirements).to have_content(
      decorated_course.other_requirements
    )

    expect(publish_course_preview_page.train_with_us).to have_content(
      provider.train_with_us
    )

    expect(publish_course_preview_page.about_accrediting_body).to have_content(
      decorated_course.about_accrediting_body
    )

    expect(publish_course_preview_page.train_with_disability).to have_content(
      provider.train_with_disability
    )

    expect(publish_course_preview_page.contact_email).to have_content(
      provider.email
    )

    expect(publish_course_preview_page.contact_telephone).to have_content(
      provider.telephone
    )

    expect(publish_course_preview_page).to have_content '2:1 or above, or equivalent'
    expect(publish_course_preview_page).to have_content 'Maths A level'

    expect(publish_course_preview_page.contact_website).to have_content(
      provider.website
    )

    expect(publish_course_preview_page.contact_address).to have_content(
      provider.address1
    )
    expect(publish_course_preview_page.contact_address).to have_content(
      provider.address2
    )
    expect(publish_course_preview_page.contact_address).to have_content(
      provider.address3
    )
    expect(publish_course_preview_page.contact_address).to have_content(
      provider.address4
    )

    expect(publish_course_preview_page).to have_choose_a_training_school_table
    expect(publish_course_preview_page.choose_a_training_school_table).not_to have_content(
      'Suspended site with vacancies'
    )

    [
      ['New site with no vacancies', 'No'],
      ['New site with vacancies', 'No'],
      ['Running site with no vacancies', 'No'],
      ['Running site with vacancies', 'Yes']
    ].each.with_index(1) do |site, index|
      name, has_vacancies_string = site

      expect(publish_course_preview_page.choose_a_training_school_table)
        .to have_selector("tbody tr:nth-child(#{index}) strong", text: name)

      expect(publish_course_preview_page.choose_a_training_school_table)
        .to have_selector("tbody tr:nth-child(#{index}) td", text: has_vacancies_string)
    end

    expect(publish_course_preview_page).to have_course_advice

    expect(publish_course_preview_page).to have_link('Apply for this course', href: "/publish/organisations/#{course.provider.provider_code}/#{course.provider.recruitment_cycle.year}/courses/#{course.course_code}/apply")
  end

  def user_with_custom_address_requested_via_zendesk
    course = build(:course, course_code: 'X104')
    provider = build(
      :provider, provider_code: '28T', courses: [course]
    )

    create(
      :user,
      providers: [
        provider
      ]
    )
  end

  def user_with_fee_based_course
    site1 = build(:site, location_name: 'Running site with vacancies')
    site2 = build(:site, location_name: 'Suspended site with vacancies')
    site3 = build(:site, location_name: 'New site with vacancies')
    site4 = build(:site, location_name: 'New site with no vacancies')
    site5 = build(:site, location_name: 'Running site with no vacancies')

    site_status1 = build(:site_status, :published, :full_time_vacancies, :running, site: site1)
    site_status2 = build(:site_status, :published, :full_time_vacancies, :suspended, site: site2)
    site_status3 = build(:site_status, :published, :full_time_vacancies, :new, site: site3)
    site_status4 = build(:site_status, :published, :with_no_vacancies, :new, site: site4)
    site_status5 = build(:site_status, :published, :with_no_vacancies, :running, site: site5)

    sites = [site1, site2, site3, site4, site5]
    site_statuses = [site_status1, site_status2, site_status3, site_status4, site_status5]

    course_enrichment = build(
      :course_enrichment, :published, course_length: :TwoYears, fee_uk_eu: 9250, fee_international: 14_000
    )

    accrediting_provider = build(:provider)

    course_subject = find_or_create(:secondary_subject, :mathematics)

    course = build(
      :course, :secondary, :fee_type_based, accrediting_provider:,
                                            site_statuses:, enrichments: [course_enrichment],
                                            degree_grade: 'two_one',
                                            degree_subject_requirements: 'Maths A level',
                                            subjects: [course_subject]
    )
    accrediting_provider_enrichment = {
      'UcasProviderCode' => accrediting_provider.provider_code,
      'Description' => Faker::Lorem.sentence
    }

    provider = build(
      :provider, sites:, courses: [course], accrediting_provider_enrichments: [accrediting_provider_enrichment]
    )

    create(
      :user,
      providers: [
        provider
      ]
    )
  end

  def user_with_no_course_enrichments
    course = build(
      :course, :secondary, :fee_type_based, degree_grade: nil, additional_degree_subject_requirements: nil
    )

    provider = build(
      :provider, courses: [course], train_with_disability: nil
    )

    create(
      :user,
      providers: [
        provider
      ]
    )
  end

  def when_i_visit_the_publish_course_preview_page
    publish_course_preview_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code
    )
  end

  alias_method :and_i_click_link, :click_link

  def then_i_should_see_the_updated_content(text)
    expect(page).to have_content(text)
  end

  def and_i_see_the_the_course_fee
    expect(page).to have_text "The course fees for UK students in #{course.recruitment_cycle.year} to #{course.recruitment_cycle.year.to_i + 1} are £100."
  end

  def and_i_submit_and_continue_through_the_two_forms
    choose('No')
    click_button('Continue')
    choose('No')
    click_button('Update degree requirements')
  end

  def and_i_am_on_the_degree_requirements_page
    expect(page).to have_text 'Do you require a minimum degree classification?'
  end

  def and_i_see_the_correct_gcse_text
    expect(page).to have_text 'We will not consider candidates with pending GCSEs.'
    expect(page).to have_text 'We will not consider candidates who need to take a GCSE equivalency test.'
  end

  def and_i_choose_no_and_submit
    page.all('.govuk-radios__item')[1].choose
    page.all('.govuk-radios__item')[3].choose
    click_button 'Update GCSEs and equivalency tests'
  end

  def and_i_see_the_correct_banner
    expect(page).to have_text 'This is a preview of how your course will appear on Find.'
  end

  def and_i_see_the_new_course_text
    expect(page).to have_text('great course')
  end

  def then_i_should_be_on_about_your_organisation_page
    expect(page).to have_text('About your organisation')
  end

  def then_i_should_be_back_on_the_preview_page
    expect(page).to have_current_path "/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/courses/#{course.course_code}/preview"
  end

  def and_i_submit_a_valid_about_your_organisation
    fill_in 'Training with your organisation', with: 'test training with disabilities'
    fill_in 'Training with disabilities and other needs', with: 'test training with disabilities'

    click_button 'Save and publish'
  end

  def and_i_submit_a_valid_form
    fill_in 'About this course',   with: 'great course'
    fill_in 'School placements',   with: 'great placement'

    click_button 'Update course information'
  end

  def and_i_submit_a_valid_course_fees
    choose '1 year'
    fill_in 'Fee for UK students', with: '100'

    click_button 'Update course length and fees'
  end

  def provider
    @provider ||= @current_user.providers.first
  end

  def recruitment_cycle
    @recruitment_cycle ||= provider.recruitment_cycle
  end

  def course
    @course ||= provider.courses.first
  end

  def decorated_course
    @decorated_course ||= course.decorate
  end

  def accrediting_provider
    @accrediting_provider ||= course.accrediting_provider
  end

  def and_i_see_financial_support
    expect(decorated_course.use_financial_support_placeholder?).to be_falsey

    expect(publish_course_preview_page.scholarship_amount).to have_content('a scholarship of £26,000')
    expect(publish_course_preview_page.bursary_amount).to have_content('a bursary of £24,000')

    expect(publish_course_preview_page).not_to have_content('Information not yet available')
  end

  def and_i_do_not_see_financial_support
    expect(publish_course_preview_page).not_to have_scholarship_amount
    expect(publish_course_preview_page).not_to have_bursary_amount
  end
end
