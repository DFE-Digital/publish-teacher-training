# frozen_string_literal: true

require 'rails_helper'

feature 'Viewing a findable course' do
  include PublishHelper

  before do
    FeatureFlag.activate(:bursaries_and_scholarships_announced)
  end

  context 'a course with international fees' do
    before do
      given_there_is_a_findable_course
    end

    scenario 'course page shows correct course information' do
      when_i_visit_the_course_page
      then_i_should_see_the_course_information
    end

    context 'end of cycle' do
      before do
        Timecop.freeze(CycleTimetable.apply_2_deadline + 1.hour)

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

  private

  def given_there_is_a_findable_course
    @course ||= create(
      :course,
      :secondary,
      :with_scitt,
      funding_type: 'fee',
      applications_open_from: '2022-01-01T00:00:00Z',
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
      provider:,
      accrediting_provider:,
      site_statuses: [
        build(:site_status, :full_time_vacancies, :findable),
        build(:site_status, :full_time_vacancies, :suspended),
        build(:site_status, :full_time_vacancies, :new),
        build(:site_status, :with_no_vacancies, :new),
        build(:site_status, :with_no_vacancies, :findable)
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
          how_school_placements_work: 'Some info about how school placements work',
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

    expect(find_course_show_page.accredited_body).to have_content(
      accrediting_provider.provider_name
    )

    expect(find_course_show_page.extended_qualification_descriptions).to have_content(
      @course.extended_qualification_descriptions
    )

    expect(find_course_show_page.qualifications).to have_content(
      'PGCE with QTS'
    )

    expect(find_course_show_page.age_range).to have_content(
      '11 to 18'
    )

    expect(find_course_show_page.funding_option).to have_content(
      @course.decorate.funding_option
    )

    expect(find_course_show_page.length).to have_content(
      '1 year - full time'
    )

    expect(find_course_show_page.applications_open_from).to have_content(
      '1 January 2022'
    )

    expect(find_course_show_page.start_date).to have_content(
      'September 2022'
    )

    expect(find_course_show_page.provider_website).to have_content(
      provider.website
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

    expect(find_course_show_page.required_qualifications).not_to have_content(
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

    expect(find_course_show_page.personal_qualities).to have_content(
      @course.latest_published_enrichment.personal_qualities
    )

    expect(find_course_show_page.other_requirements).to have_content(
      @course.latest_published_enrichment.other_requirements
    )

    expect(find_course_show_page.train_with_us).to have_content(
      provider.train_with_us
    )

    expect(find_course_show_page.about_accrediting_body).to have_content(
      @course.decorate.about_accrediting_body
    )

    expect(find_course_show_page.train_with_disability).to have_content(
      provider.train_with_disability
    )

    expect(find_course_show_page.contact_email).to have_content(
      provider.email
    )

    expect(find_course_show_page.contact_telephone).to have_content(
      provider.telephone
    )

    expect(find_course_show_page.contact_website).to have_content(
      provider.website
    )

    expect(find_course_show_page.contact_address).to have_content(
      [@provider.address1, @provider.address2, @provider.address3, @provider.address4, @provider.postcode].compact.join(' ')
    )

    expect(find_course_show_page.school_placements).not_to have_content('Suspended site with vacancies')

    @course.site_statuses.new_or_running.map(&:site).uniq.each do |site|
      expect(find_course_show_page).to have_content(smart_quotes(site.decorate.full_address))
    end

    expect(find_course_show_page).to have_course_advice

    expect(find_course_show_page.apply_link.text).to eq('Apply for this course')

    expect(find_course_show_page.apply_link[:href]).to eq("/course/#{provider.provider_code}/#{@course.course_code}/apply")

    expect(find_course_show_page).not_to have_content('When you apply you’ll need these codes for the Choices section of your application form')

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
        'Description' => 'Something great about the accredited body',
        'UcasProviderCode' => accrediting_provider.provider_code
      }]
    )
  end

  def accrediting_provider
    @accrediting_provider ||= create(
      :provider,
      :accredited_body,
      provider_name: 'Accrediting Provider 1'
    )
  end
end
