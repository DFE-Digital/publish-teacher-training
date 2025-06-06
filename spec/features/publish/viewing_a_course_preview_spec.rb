# frozen_string_literal: true

require "rails_helper"

feature "Course show" do
  include Rails.application.routes.url_helpers

  context "bursaries and scholarships is announced" do
    before do
      FeatureFlag.activate(:bursaries_and_scholarships_announced)
    end

    scenario "i can view the course basic details" do
      Timecop.travel(Find::CycleTimetable.mid_cycle) do
        given_i_am_authenticated(user: user_with_fee_based_course)
        when_i_visit_the_publish_course_preview_page
        then_i_see_the_course_preview_details
        and_i_see_financial_support
      end
    end
  end

  context "with empty sections" do
    scenario "blank about the training provider" do
      given_i_am_authenticated(user: user_with_no_course_enrichments)
      when_i_visit_the_publish_course_preview_page
      and_i_click_link_or_button(@course.provider_name)
      and_i_click_link_or_button("Enter details about the training provider")
      then_i_should_be_on_about_your_organisation_page
      and_i_click_link_or_button("Back")
      then_i_should_be_back_on_the_provider_page
      and_i_click_link_or_button("Enter details about the training provider")
      then_i_see_markdown_formatting_guidance_for_each_field
      and_i_submit_a_valid_about_your_organisation
      then_i_should_be_back_on_the_provider_page
      then_i_should_see_the_updated_content("test training with your organisation")
    end

    scenario "blank training with disabilities and other needs" do
      given_i_am_authenticated(user: user_with_no_course_enrichments)
      when_i_visit_the_publish_course_preview_page
      and_i_click_link_or_button("Find out about training with disabilities and other needs at #{@course.provider_name}")
      and_i_click_link_or_button("Enter details about training with disabilities and other needs")
      then_i_should_be_on_about_your_organisation_page
      and_i_click_link_or_button("Back")
      then_i_should_be_on_the_training_with_disabilities_page
      and_i_click_link_or_button("Enter details about training with disabilities and other needs")
      and_i_submit_a_valid_about_your_organisation
      then_i_should_be_on_the_training_with_disabilities_page
      then_i_should_see_the_updated_content("test training with disabilities")
      and_i_click_link_or_button("Back to #{@course.name} (#{course.course_code})")
      then_i_should_be_back_on_the_preview_page
    end

    scenario "blank school placements section" do
      given_i_am_authenticated(user: user_with_no_course_enrichments)
      when_i_visit_the_publish_course_preview_page
      and_i_click_link_or_button("Enter details about how placements work")
      and_i_click_link_or_button("Back")
      and_i_click_link_or_button("Enter details about how placements work")
      and_i_submit_a_valid_form
      and_i_see_the_correct_banner
      and_i_see_the_new_course_text
      then_i_should_be_back_on_the_preview_page
    end

    scenario "blank degree requirements" do
      given_i_am_authenticated(user: user_with_no_course_enrichments)
      when_i_visit_the_publish_course_preview_page
      and_i_click_link_or_button("Enter degree requirements")
      and_i_am_on_the_degree_requirements_page
      and_i_click_link_or_button("Back")
      then_i_should_be_back_on_the_preview_page
      and_i_click_link_or_button("Enter degree requirements")
      and_i_submit_and_continue_through_the_two_forms
      then_i_should_see_the_updated_content("Bachelor’s degree or equivalent qualification")
    end

    scenario "blank gcse requirements" do
      given_i_am_authenticated(user: user_with_no_course_enrichments)
      when_i_visit_the_publish_course_preview_page
      and_i_click_link_or_button("Enter GCSE and equivalency test requirements")
      and_i_click_link_or_button("Back")
      and_i_click_link_or_button("Enter GCSE and equivalency test requirements")
      and_i_choose_no_and_submit
      and_i_see_the_correct_banner
      and_i_see_the_correct_gcse_text
      then_i_should_be_back_on_the_preview_page
    end

    scenario "blank school placements" do
      given_i_am_authenticated(user: user_with_no_course_enrichments)
      when_i_visit_the_publish_course_preview_page
      and_i_click_link_or_button("Enter details about how placements work")
      and_i_click_link_or_button("Back")
      and_i_click_link_or_button("Enter details about how placements work")
      and_i_submit_a_valid_form
      and_i_see_the_correct_banner
      then_i_should_be_back_on_the_preview_page
    end

    scenario "blank fees uk eu" do
      given_i_am_authenticated(user: user_with_no_course_enrichments)
      when_i_visit_the_publish_course_preview_page
      and_i_click_link_or_button("Enter details about fees and financial support")
      and_i_click_link_or_button("Back")
      and_i_click_link_or_button("Enter details about fees and financial support")
      and_i_submit_a_valid_course_fees
      and_i_see_the_correct_banner
      and_i_see_the_the_course_fee
      then_i_should_be_back_on_the_preview_page
    end
  end

  context "bursaries and scholarships is not announced" do
    scenario "i can view the course basic details" do
      Timecop.travel(Find::CycleTimetable.apply_deadline - 1.hour) do
        given_i_am_authenticated(user: user_with_fee_based_course)
        when_i_visit_the_publish_course_preview_page
        then_i_see_the_course_preview_details
        and_i_do_not_see_financial_support
      end
    end
  end

  context "contact details for London School of Jewish Studies and the course code is X104" do
    scenario "renders the custom address requested via zendesk" do
      given_i_am_authenticated(
        user: user_with_custom_address_requested_via_zendesk,
      )
      when_i_visit_the_publish_course_preview_page
      and_i_click_link_or_button(@course.provider_name)
      then_i_see_custom_address
    end
  end

  scenario "user sees no school placements" do
    create(:recruitment_cycle, :next)
    Timecop.travel(Find::CycleTimetable.find_opens) do
      given_i_am_authenticated(user: user_with_fee_based_course)
      provider.update(selectable_school: false)
      when_i_visit_the_publish_course_preview_page
      then_i_see_no_school_placements_link
    end
  end

  scenario "user sees school placements" do
    Timecop.travel(Find::CycleTimetable.find_opens) do
      given_i_am_authenticated(user: user_with_fee_based_course)
      when_i_visit_the_publish_course_preview_page
      and_i_click_link_or_button("View list of school placements")
      then_i_should_be_on_the_school_placements_page
      and_i_click_link_or_button("Back to #{@course.name} (#{course.course_code})")
      then_i_should_be_back_on_the_preview_page
    end
  end

  scenario "user views provider and accredited_provider" do
    Timecop.travel(Find::CycleTimetable.mid_cycle) do
      given_i_am_authenticated(user: user_with_fee_based_course)
      when_i_visit_the_publish_course_preview_page
      and_i_click_link_or_button(@course.provider_name)
      then_i_should_be_on_the_provider_page
      and_i_click_link_or_button("Back to #{@course.name} (#{course.course_code})")
      and_i_click_link_or_button(@course.accrediting_provider.provider_name)
      then_i_should_be_on_the_accrediting_provider_page
      and_i_click_link_or_button("Back to #{@course.name} (#{course.course_code})")
      then_i_should_be_back_on_the_preview_page
    end
  end

private

  def then_i_see_custom_address
    expect(publish_course_preview_page).to have_content "LSJS"
    expect(publish_course_preview_page).to have_content "44A Albert Road"
    expect(publish_course_preview_page).to have_content "London"
    expect(publish_course_preview_page).to have_content "NW4 2SJ"
  end

  def then_i_see_markdown_formatting_guidance_for_each_field
    %w[#publish-about-your-organisation-form-train-with-us-hint #publish-about-your-organisation-form-train-with-disability-hint].each do |section_id|
      within("div#{section_id}") do
        page.find("span", text: "Help formatting your text")
        expect(page).to have_content "How to format your text"
        expect(page).to have_content "How to create a link"
        expect(page).to have_content "How to create bullet points"
      end
    end
  end

  def then_i_see_the_course_preview_details
    expect(publish_course_preview_page.title).to have_content(
      "#{course.name} (#{course.course_code})",
    )

    expect(publish_course_preview_page.sub_title).to have_content(
      provider.provider_name,
    )

    expect(publish_course_preview_page).to have_content(
      "QTS with PGCE",
    )

    expect(publish_course_preview_page).to have_content(
      "Visas cannot be sponsored",
    )

    expect(publish_course_preview_page).to have_content(
      "11 to 18",
    )

    expect(publish_course_preview_page).to have_content(
      "Up to 2 years - full time",
    )
    expect(publish_course_preview_page).to have_content(
      course.applications_open_from.strftime("%-d %B %Y"),
    )

    expect(publish_course_preview_page).to have_content(
      "September #{recruitment_cycle.year}",
    )

    expect(publish_course_preview_page).not_to have_vacancies

    expect(publish_course_preview_page.about_course).to have_content(
      decorated_course.about_course,
    )

    expect(publish_course_preview_page.interview_process).to have_content(
      decorated_course.interview_process,
    )

    expect(publish_course_preview_page.school_placements).to have_content(
      decorated_course.how_school_placements_work,
    )

    expect(publish_course_preview_page).to have_content(
      "The course fees for #{recruitment_cycle.year} to #{recruitment_cycle.year.to_i + 1} are as follows",
    )

    expect(publish_course_preview_page.uk_fees).to have_content(
      "£9,250",
    )

    expect(publish_course_preview_page.international_fees).to have_content(
      "£14,000",
    )

    expect(publish_course_preview_page.fee_details).to have_content(
      decorated_course.fee_details,
    )

    expect(publish_course_preview_page).not_to have_salary_details

    expect(publish_course_preview_page).to have_content(
      "Training with disabilities",
    )

    expect(publish_course_preview_page).to have_content "2:1 bachelor’s degree or above or equivalent qualification"
    expect(publish_course_preview_page).to have_content "Maths A level"

    expect(publish_course_preview_page).to have_link("View list of school placements")

    expect(publish_course_preview_page).to have_course_advice

    has_apply_for_course_buttons
  end

  def has_apply_for_course_buttons
    expected_url = "/publish/organisations/#{course.provider.provider_code}/#{course.provider.recruitment_cycle.year}/courses/#{course.course_code}/apply"

    expect(page).to have_link("Apply for this course", href: expected_url, count: 2)
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
    study_site = build(:site, :study_site, location_name: "Study site")

    site_status1 = build(:site_status, :published, :full_time_vacancies, :running, site: site1)
    site_status2 = build(:site_status, :published, :full_time_vacancies, :suspended, site: site2)
    site_status3 = build(:site_status, :published, :full_time_vacancies, :new_status, site: site3)
    site_status4 = build(:site_status, :published, :no_vacancies, :new_status, site: site4)
    site_status5 = build(:site_status, :published, :no_vacancies, :running, site: site5)

    sites = [site1, site2, site3, site4, site5]
    site_statuses = [site_status1, site_status2, site_status3, site_status4, site_status5]

    course_enrichment = build(
      :course_enrichment, :published, course_length: :TwoYears, fee_uk_eu: 9250, fee_international: 14_000
    )

    accrediting_provider = build(:accredited_provider)

    course_subject = find_or_create(:secondary_subject, :mathematics)

    course = build(
      :course,
      :open,
      :secondary,
      funding: "fee",
      applications_open_from: RecruitmentCycle.current.application_end_date - 1.minute,
      accrediting_provider:,
      site_statuses:, enrichments: [course_enrichment],
      study_sites: [study_site],
      degree_grade: "two_one",
      degree_subject_requirements: "Maths A level",
      subjects: [course_subject]
    )

    provider = build(
      :provider, sites:, study_sites: [study_site], courses: [course], accredited_partnerships: [build(:provider_partnership, accredited_provider: accrediting_provider)]
    )

    create(
      :user,
      providers: [
        provider,
      ],
    )
  end

  def user_with_no_course_enrichments
    provider = create(
      :provider, train_with_disability: nil, train_with_us: nil
    )

    course = create(
      :course, :secondary, :with_accrediting_provider, provider:, degree_grade: nil, funding: "fee", additional_degree_subject_requirements: nil
    )

    provider.accredited_partnerships.create(accredited_provider: course.accrediting_provider)

    create(
      :user,
      providers: [
        provider,
      ],
    )
  end

  def when_i_visit_the_publish_course_preview_page
    publish_course_preview_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  alias_method :and_i_click_link_or_button, :click_link_or_button

  def then_i_should_see_the_updated_content(text)
    expect(page).to have_content(text)
  end

  def and_i_see_the_the_course_fee
    expect(page).to have_text "The course fees for UK citizens in #{course.recruitment_cycle.year} to #{course.recruitment_cycle.year.to_i + 1} are £100."
  end

  def and_i_submit_and_continue_through_the_two_forms
    choose("No")
    click_link_or_button("Continue")
    choose("No")
    click_link_or_button("Update degree requirements")
  end

  def and_i_am_on_the_degree_requirements_page
    expect(page).to have_text "Do you require a minimum degree classification?"
  end

  def and_i_see_the_correct_gcse_text
    expect(page).to have_text "We will not consider candidates with pending GCSEs."
    expect(page).to have_text "We will not consider candidates who need to take a GCSE equivalency test."
  end

  def and_i_choose_no_and_submit
    page.all(".govuk-radios__item")[1].choose
    page.all(".govuk-radios__item")[3].choose
    click_link_or_button "Update GCSEs and equivalency tests"
  end

  def and_i_see_the_correct_banner
    expect(page).to have_text "This is a preview of how your course will appear on Find."
  end

  def and_i_see_the_new_course_text
    expect(page).to have_text("great placement")
  end

  def then_i_should_be_on_about_your_organisation_page
    expect(page).to have_text("About your organisation")
  end

  def then_i_should_be_back_on_the_preview_page
    expect(page).to have_current_path "/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/courses/#{course.course_code}/preview"
  end

  def then_i_should_be_back_on_the_provider_page
    expect(page).to have_current_path(
      "/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/courses/#{course.course_code}/provider",
    )
  end

  def and_i_submit_a_valid_about_your_organisation
    fill_in "Training with your organisation", with: "test training with your organisation"
    fill_in "Training with disabilities and other needs", with: "test training with disabilities"

    click_link_or_button "Save and publish"
  end

  def and_i_submit_a_valid_form
    fill_in "How placements work", with: "great placement"

    click_link_or_button "Update how placements work"
  end

  def and_i_submit_a_valid_course_fees
    fill_in "Fee for UK students", with: "100"

    click_link_or_button "Update course fees"
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

    expect(publish_course_preview_page.scholarship_amount).to have_content("Bursaries of £24,000 and scholarships of £26,000 are available to eligible trainees.")

    expect(publish_course_preview_page).to have_no_content("Information not yet available")
  end

  def and_i_do_not_see_financial_support
    expect(publish_course_preview_page).to have_no_content("Bursaries")
    expect(publish_course_preview_page).to have_no_content("Scholarships")
  end

  def then_i_should_be_on_the_school_placements_page
    expect(publish_course_preview_page).to have_school_placements_table
  end

  def then_i_should_be_on_the_provider_page
    expect(publish_course_preview_page.train_with_us).to have_content(
      provider.train_with_us,
    )

    expect(publish_course_preview_page).to have_content(
      provider.email,
    )

    expect(publish_course_preview_page).to have_content(
      provider.telephone,
    )

    expect(publish_course_preview_page).to have_content(
      provider.website,
    )

    expect(publish_course_preview_page).to have_content(
      provider.address1,
    )
    expect(publish_course_preview_page).to have_content(
      provider.address2,
    )
    expect(publish_course_preview_page).to have_content(
      provider.address3,
    )
    expect(publish_course_preview_page).to have_content(
      provider.town,
    )
    expect(publish_course_preview_page).to have_content(
      provider.address4,
    )
  end

  def then_i_should_be_on_the_accrediting_provider_page
    expect(page).to have_content(
      accrediting_provider.provider_name,
    )

    expect(publish_course_preview_page.about_accrediting_provider).to have_content(
      decorated_course.about_accrediting_provider,
    )
  end

  def then_i_should_be_on_the_training_with_disabilities_page
    expect(publish_course_preview_page.train_with_disability).to have_content(
      provider.train_with_disability,
    )

    expect(page).to have_link(
      "Contact #{course.provider_name}",
      href: provider_publish_provider_recruitment_cycle_course_path(
        @course.provider_code,
        @course.recruitment_cycle_year,
        @course.course_code,
      ),
    )
  end

  def then_i_see_no_school_placements_link
    expect(publish_course_preview_page).to have_no_link("View list of school placements")
  end
end
