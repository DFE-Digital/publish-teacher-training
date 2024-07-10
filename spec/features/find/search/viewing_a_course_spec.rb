# frozen_string_literal: true

require 'rails_helper'

feature 'Viewing a findable course' do
  include PublishHelper
  include Rails.application.routes.url_helpers

  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    FeatureFlag.activate(:bursaries_and_scholarships_announced)
  end

  context 'a course with international fees' do
    before do
      given_there_is_a_findable_course
    end

    scenario 'course page shows correct course information' do
      Timecop.freeze(Find::CycleTimetable.apply_deadline - 1.hour) do
        when_i_visit_the_course_page
        then_i_should_see_the_course_information
      end
    end

    context 'end of cycle' do
      before do
        Timecop.freeze(Find::CycleTimetable.apply_deadline + 1.hour)

        when_i_visit_the_course_page
      end

      after do
        Timecop.return
      end

      scenario "does not display the 'apply for this course' button" do
        then_i_should_not_see_the_apply_button
      end

      scenario 'renders the deadline banner' do
        then_i_should_see_the_deadline_banner
      end
    end

    context 'showing the back button' do
      context 'when navigating directly to the course' do
        scenario 'it does not display the back link' do
          when_i_visit_the_course_page
          then_i_should_not_see_the_back_link
        end
      end

      context 'when navigating to the course from the search results page' do
        scenario 'it displays the back link' do
          set_referrer
          when_i_visit_the_course_page
          then_i_should_see_the_back_link
        end
      end
    end
  end

  context 'a course with no international fees' do
    scenario 'it only displays UK fees' do
      given_there_is_a_findable_course_with_no_international_fees
      when_i_visit_the_course_page
      then_i_should_only_see_the_uk_fees
    end
  end

  scenario 'user views school placements' do
    given_there_is_a_findable_course
    when_i_visit_the_course_page
    when_i_click('View list of school placements')
    then_i_should_be_on_the_school_placements_page
    when_i_click("Back to #{@course.name} (#{course.course_code})")
    then_i_should_be_on_the_course_page
  end

  scenario 'user views provider and accredited_provider' do
    given_there_is_a_findable_course
    when_i_visit_the_course_page
    when_i_click(@course.provider_name)
    then_i_should_be_on_the_provider_page
    when_i_click("Back to #{@course.name} (#{course.course_code})")
    when_i_click(@course.accrediting_provider.provider_name)
    then_i_should_be_on_the_accrediting_provider_page
    when_i_click("Back to #{@course.name} (#{course.course_code})")
    then_i_should_be_on_the_course_page
  end

  scenario 'user views the training with disabilities page' do
    given_there_is_a_findable_course
    when_i_visit_the_course_page
    when_i_click("Find out about training with disabilities and other needs at #{@course.provider_name}")
    then_i_should_be_on_the_training_with_disabilities_page
    when_i_click("Back to #{@course.name} (#{course.course_code})")
    then_i_should_be_on_the_course_page
  end

  private

  def given_there_is_a_findable_course
    @course ||= create(
      :course,
      :secondary,
      :with_scitt,
      funding_type: 'fee',
      start_date: '2022-09-01T00:00:00Z',
      degree_grade: 'two_one',
      additional_degree_subject_requirements: true,
      degree_subject_requirements: 'Certificate must be print in blue ink',
      accept_pending_gcse: true,
      accept_gcse_equivalency: true,
      accept_english_gcse_equivalency: true,
      accept_maths_gcse_equivalency: false,
      accept_science_gcse_equivalency: false,
      additional_gcse_equivalencies: 'You need to work hard',
      can_sponsor_student_visa: true,
      can_sponsor_skilled_worker_visa: false,
      application_status: 'open',
      provider:,
      accrediting_provider:,
      site_statuses: [
        build(:site_status, :full_time_vacancies, :findable),
        build(:site_status, :full_time_vacancies, :suspended),
        build(:site_status, :full_time_vacancies, :new_status),
        build(:site_status, :no_vacancies, :new_status),
        build(:site_status, :no_vacancies, :findable)
      ],
      enrichments: [
        build(
          :course_enrichment,
          :published,
          course_length: 'OneYear',
          fee_uk_eu: '9250',
          fee_international: '9250',
          fee_details: 'Optional fee details',
          personal_qualities: 'We are looking for ambitious trainee teachers who are passionate.',
          other_requirements: 'You will need three years of prior work experience, but not necessarily in an educational context.',
          interview_process: 'Some helpful guidance about the interview process',
          how_school_placements_work: 'Some info about how placements work',
          about_course: 'This is a course',
          required_qualifications: 'You need some qualifications for this course'
        )
      ],
      subjects: [
        build(
          :secondary_subject,
          :chemistry,
          scholarship: '2000',
          bursary_amount: '4000'
        )
      ]
    )
  end

  def given_there_is_a_findable_course_with_no_international_fees
    @course ||= create(
      :course,
      :secondary,
      :with_scitt,
      funding_type: 'fee',
      enrichments: [
        build(
          :course_enrichment,
          :published,
          fee_uk_eu: '9250',
          fee_international: nil
        )
      ]
    )
  end

  def when_i_visit_the_course_page
    find_course_show_page.load(provider_code: @course.provider.provider_code, course_code: @course.course_code)
  end

  def then_i_should_see_the_course_information
    expect(find_course_show_page.title).to have_content(
      "#{@course.name} (#{@course.course_code})"
    )

    expect(find_course_show_page.sub_title).to have_content(
      provider.provider_name
    )

    expect(find_course_show_page).to have_content(
      'QTS with PGCE'
    )

    expect(find_course_show_page).to have_content(
      '11 to 18'
    )

    expect(find_course_show_page).to have_content(
      @course.decorate.funding_option
    )

    expect(find_course_show_page).to have_content(
      '1 year - full time'
    )

    expect(find_course_show_page).to have_content(
      'September 2022'
    )

    expect(find_course_show_page).not_to have_vacancies

    expect(find_course_show_page.about_course).to have_content(
      @course.latest_published_enrichment.about_course
    )

    expect(find_course_show_page.interview_process).to have_content(
      @course.latest_published_enrichment.interview_process
    )

    expect(find_course_show_page.school_placements).to have_content(
      @course.latest_published_enrichment.how_school_placements_work
    )

    expect(find_course_show_page.uk_fees).to have_content(
      '£9,250'
    )

    expect(find_course_show_page.international_fees).to have_content(
      '£9,250'
    )

    expect(find_course_show_page.fee_details).to have_content(
      @course.decorate.fee_details
    )

    expect(find_course_show_page).not_to have_salary_details

    expect(find_course_show_page.scholarship_amount).to have_content('a scholarship of £2,000')

    expect(find_course_show_page.bursary_amount).to have_content('a bursary of £4,000')

    expect(find_course_show_page.financial_support_details).to have_content('Financial support from the training provider')

    expect(find_course_show_page.required_qualifications).to have_no_content(
      @course.latest_published_enrichment.required_qualifications
    )

    expect(find_course_show_page).to have_international_students
    expect(find_course_show_page.international_students).to have_content(
      'Before you apply for this course, contact us to check Student visa sponsorship is available. If it is, and you get a place on this course, we’ll help you apply for your visa.'
    )

    expect(find_course_show_page.required_qualifications).to have_content(
      'Grade 4 (C) or above in English and maths, or equivalent qualification.'
    )
    expect(find_course_show_page.required_qualifications).to have_content(
      'We’ll consider candidates with pending GCSEs.'
    )
    expect(find_course_show_page.required_qualifications).to have_content(
      'We’ll consider candidates who need to take a GCSE equivalency test in English.'
    )
    expect(find_course_show_page.required_qualifications).to have_content(
      'You need to work hard'
    )

    expect(find_course_show_page.required_qualifications).to have_content(
      '2:1 or above, or equivalent.'
    )
    expect(find_course_show_page.required_qualifications).to have_content(
      'Certificate must be print in blue ink'
    )

    expect(find_course_show_page).to have_content(
      'Training with disabilities'
    )

    expect(find_course_show_page.school_placements).to have_no_content('Suspended site with vacancies')

    expect(find_course_show_page).to have_link('View list of school placements')

    expect(find_course_show_page).to have_course_advice

    expect(find_course_show_page.apply_link.text).to eq('Apply for this course')

    expect(find_course_show_page.apply_link[:href]).to eq("/course/#{provider.provider_code}/#{@course.course_code}/apply")

    expect(find_course_show_page).to have_no_content('When you apply you’ll need these codes for the Choices section of your application form')

    expect(find_course_show_page).not_to have_end_of_cycle_notice

    expect(find_course_show_page.feedback_link[:href]).to eq("https://www.apply-for-teacher-training.service.gov.uk/candidate/find-feedback?path=/course/#{provider.provider_code}/#{@course.course_code}&find_controller=find/courses")
  end

  def then_i_should_not_see_the_apply_button
    expect(find_course_show_page).not_to have_apply_link
    expect(find_course_show_page).to have_end_of_cycle_notice
  end

  def then_i_should_see_the_deadline_banner
    expect(page).to have_content 'Courses are currently closed but you can get your application ready'
  end

  def set_referrer
    page.driver.header('Referer', 'http://localhost:9000/results')
  end

  def then_i_should_not_see_the_back_link
    expect(find_course_show_page).not_to have_back_link
  end

  def then_i_should_see_the_back_link
    expect(find_course_show_page).to have_back_link
  end

  def then_i_should_only_see_the_uk_fees
    expect(find_course_show_page).to have_content(
      "The course fees for UK students in #{RecruitmentCycle.current.year} to #{RecruitmentCycle.current.year.to_i + 1} are £9,250"
    )

    expect(find_course_show_page).not_to have_international_fees
  end

  def provider
    @provider ||= create(
      :provider,
      :scitt,
      provider_name: 'Provider 1',
      accrediting_provider_enrichments: [{
        'Description' => 'Something great about the accredited provider',
        'UcasProviderCode' => accrediting_provider.provider_code
      }]
    )
  end

  def accrediting_provider
    @accrediting_provider ||= create(
      :provider,
      :accredited_provider,
      provider_name: 'Accrediting Provider 1'
    )
  end

  def when_i_click(button)
    click_on(button)
  end

  def then_i_should_be_on_the_school_placements_page
    @course.site_statuses.new_or_running.map(&:site).uniq.each do |site|
      expect(find_course_show_page).to have_content(smart_quotes(site.decorate.full_address))
    end
  end

  def then_i_should_be_on_the_provider_page
    expect(find_course_show_page.train_with_us).to have_content(
      provider.train_with_us
    )

    expect(find_course_show_page).to have_content(
      provider.email
    )

    expect(find_course_show_page).to have_content(
      provider.telephone
    )

    expect(find_course_show_page).to have_content(
      provider.website
    )

    expect(find_course_show_page).to have_content(
      [@provider.address1, @provider.address2, @provider.address3, @provider.town, @provider.address4, @provider.postcode].compact.join(' ')
    )
  end

  def then_i_should_be_on_the_accrediting_provider_page
    expect(find_course_show_page.about_accrediting_provider).to have_content(
      @course.decorate.about_accrediting_provider
    )

    expect(find_course_show_page).to have_content(
      accrediting_provider.provider_name
    )
  end

  def then_i_should_be_on_the_course_page
    expect(page.current_url).to eq(
      URI.join(
        Settings.search_ui.base_url,
        "/course/#{@course.provider_code}/#{@course.course_code}"
      ).to_s
    )
  end

  def then_i_should_be_on_the_training_with_disabilities_page
    expect(find_course_show_page.train_with_disability).to have_content(
      provider.train_with_disability
    )

    expect(page).to have_link(
      "Contact #{course.provider_name}",
      href: find_provider_path(@course.provider_code, @course.course_code)
    )
  end
end
