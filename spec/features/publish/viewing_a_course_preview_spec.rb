# frozen_string_literal: true

require "rails_helper"

feature "Course show", { can_edit_current_and_next_cycles: false } do
  scenario "i can view the course basic details" do
    given_i_am_authenticated(user: user_with_fee_based_course)
    when_i_visit_the_course_preview_page
    then_i_see_the_course_preview_details
  end

  context "contact details for London School of Jewish Studies and the course code is X104" do
    scenario "renders the custom address requested via zendesk" do
      given_i_am_authenticated(
        user: user_with_custom_address_requested_via_zendesk,
      )
      when_i_visit_the_course_preview_page
      then_i_see_custom_address
    end
  end

private

  def then_i_see_custom_address
    expect(course_preview_page).to have_content "LSJS"
    expect(course_preview_page).to have_content "44A Albert Road"
    expect(course_preview_page).to have_content "London"
    expect(course_preview_page).to have_content "NW4 2SJ"
  end

  def then_i_see_the_course_preview_details
    expect_financial_support

    expect(course_preview_page.title).to have_content(
      "#{course.name} (#{course.course_code})",
    )

    expect(course_preview_page.sub_title).to have_content(
      provider.provider_name,
    )

    expect(course_preview_page.accredited_body).to have_content(
      accrediting_provider.provider_name,
    )

    expect(course_preview_page.description).to have_content(
      course.description,
    )

    expect(course_preview_page.qualifications).to have_content(
      "PGCE with QTS",
    )

    expect(course_preview_page.age_range_in_years).to have_content(
      "11 to 18",
    )

    expect(course_preview_page.funding_option).to have_content(
      decorated_course.funding_option,
    )

    expect(course_preview_page.length).to have_content(
      decorated_course.length,
    )

    expect(course_preview_page.applications_open_from).to have_content(
      course.applications_open_from.strftime("%-d %B %Y"),
    )

    expect(course_preview_page.start_date).to have_content(
      "September #{recruitment_cycle.year}",
    )

    expect(course_preview_page.provider_website).to have_content(
      provider.website,
    )

    expect(course_preview_page).not_to have_vacancies

    expect(course_preview_page.about_course).to have_content(
      decorated_course.about_course,
    )

    expect(course_preview_page.interview_process).to have_content(
      decorated_course.interview_process,
    )

    expect(course_preview_page.school_placements).to have_content(
      decorated_course.how_school_placements_work,
    )

    expect(course_preview_page).to have_content(
      "The course fees for #{recruitment_cycle.year} to #{recruitment_cycle.year.to_i + 1} are as follows",
    )

    expect(course_preview_page.uk_fees).to have_content(
      "£9,250",
    )

    expect(course_preview_page.international_fees).to have_content(
      "£14,000",
    )

    expect(course_preview_page.fee_details).to have_content(
      decorated_course.fee_details,
    )

    expect(course_preview_page).not_to have_salary_details

    expect(course_preview_page.financial_support_details).to have_content(
      "Financial support from the training provider",
    )

    expect(course_preview_page.personal_qualities).to have_content(
      decorated_course.personal_qualities,
    )

    expect(course_preview_page.other_requirements).to have_content(
      decorated_course.other_requirements,
    )

    expect(course_preview_page.train_with_us).to have_content(
      provider.train_with_us,
    )

    expect(course_preview_page.about_accrediting_body).to have_content(
      decorated_course.about_accrediting_body,
    )

    expect(course_preview_page.train_with_disability).to have_content(
      provider.train_with_disability,
    )

    expect(course_preview_page.contact_email).to have_content(
      provider.email,
    )

    expect(course_preview_page.contact_telephone).to have_content(
      provider.telephone,
    )

    expect(course_preview_page).to have_content "2:1 or above, or equivalent"
    expect(course_preview_page).to have_content "Maths A level"

    expect(course_preview_page.contact_website).to have_content(
      provider.website,
    )

    expect(course_preview_page.contact_address).to have_content(
      provider.full_address,
    )

    expect(course_preview_page).to have_choose_a_training_location_table
    expect(course_preview_page.choose_a_training_location_table).not_to have_content(
      "Suspended site with vacancies",
    )

    [
      ["New site with no vacancies", "No"],
      ["New site with vacancies", "No"],
      ["Running site with no vacancies", "No"],
      ["Running site with vacancies", "Yes"],
    ].each.with_index(1) do |site, index|
      name, has_vacancies_string = site

      expect(course_preview_page.choose_a_training_location_table)
        .to have_selector("tbody tr:nth-child(#{index}) strong", text: name)

      expect(course_preview_page.choose_a_training_location_table)
        .to have_selector("tbody tr:nth-child(#{index}) td", text: has_vacancies_string)
    end

    expect(course_preview_page).to have_course_advice
  end

  def user_with_custom_address_requested_via_zendesk
    course = build(:course, course_code: "X104")
    provider = build(
      :provider, provider_code: "28T", courses: [course]
    )

    create(
      :user,
      providers: [
        provider,
      ],
    )
  end

  def user_with_fee_based_course
    site1 = build(:site, location_name: "Running site with vacancies")
    site2 = build(:site, location_name: "Suspended site with vacancies")
    site3 = build(:site, location_name: "New site with vacancies")
    site4 = build(:site, location_name: "New site with no vacancies")
    site5 = build(:site, location_name: "Running site with no vacancies")

    site_status1 = build(:site_status, :published, :full_time_vacancies, :running, site: site1)
    site_status2 = build(:site_status, :published, :full_time_vacancies, :suspended, site: site2)
    site_status3 = build(:site_status, :published, :full_time_vacancies, :new, site: site3)
    site_status4 = build(:site_status, :published, :with_no_vacancies, :new, site: site4)
    site_status5 = build(:site_status, :published, :with_no_vacancies, :running, site: site5)

    sites = [site1, site2, site3, site4, site5]
    site_statuses = [site_status1, site_status2, site_status3, site_status4, site_status5]

    course_enrichment = build(
      :course_enrichment, :published, course_length: :TwoYears, fee_uk_eu: 9250, fee_international: 14000
    )

    accrediting_provider = build(:provider)

    course_subject = find_or_create(:secondary_subject, :mathematics)

    course = build(
      :course, :secondary, :fee_type_based, accrediting_provider:,
      site_statuses:, enrichments: [course_enrichment],
      degree_grade: "two_one",
      degree_subject_requirements: "Maths A level",
      subjects: [course_subject]
    )
    accrediting_provider_enrichment = {
      "UcasProviderCode" => accrediting_provider.provider_code,
      "Description" => Faker::Lorem.sentence,
    }

    provider = build(
      :provider, sites:, courses: [course], accrediting_provider_enrichments: [accrediting_provider_enrichment]
    )

    create(
      :user,
      providers: [
        provider,
      ],
    )
  end

  def when_i_visit_the_course_preview_page
    course_preview_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
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

  def expect_financial_support
    # NOTE: There is a period at the beginning of the new/current
    #       recruitment cycle whereby the financial incentives
    #       announcement is still pending.

    financial_incentives_been_announced = true

    if financial_incentives_been_announced
      expect_financial_incentives
    else
      expect_financial_support_placeholder
    end
  end

  def expect_financial_support_placeholder
    expect(decorated_course.use_financial_support_placeholder?).to be_truthy

    expect(course_preview_page.find(".govuk-inset-text"))
      .to have_text("Financial support for 2021 to 2022 will be announced soon. Further information is available on Get Into Teaching.")
    expect(course_preview_page).not_to have_scholarship_amount
    expect(course_preview_page).not_to have_bursary_amount
  end

  def expect_financial_incentives
    expect(decorated_course.use_financial_support_placeholder?).to be_falsey

    expect(course_preview_page.scholarship_amount).to have_content("a scholarship of £26,000")
    expect(course_preview_page.bursary_amount).to have_content("a bursary of £24,000")
  end
end
