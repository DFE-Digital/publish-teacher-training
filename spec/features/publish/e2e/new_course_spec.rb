# frozen_string_literal: true

require "rails_helper"

feature "new course", { can_edit_current_and_next_cycles: false } do
  scenario "creates the correct course in the next cycle" do
    # This is intended to be a test which will go through the entire flow
    # and ensure that the correct page gets displayed at the end
    # with the correct course being created
    given_i_am_authenticated_as_a_provider_user_in_the_next_cycle
    and_the_visa_sponsor_deadline_feature_flag_is_on
    when_i_visit_the_courses_page
    and_i_click_on_add_course
    then_i_can_create_the_course
  end

private

  def then_i_can_create_the_course
    expect(publish_courses_new_level_page).to be_displayed
    course_creation_params = select_level({}, level: "primary", level_selection: publish_courses_new_level_page.level_fields.primary, next_page: publish_courses_new_subjects_page)
    course_creation_params = select_subjects(course_creation_params, level: "primary", next_page: publish_courses_new_age_range_page)

    course_creation_params = select_age_range(course_creation_params, next_page: publish_courses_new_outcome_page)

    course_creation_params = select_outcome(course_creation_params, qualification: "qts", qualification_selection: publish_courses_new_outcome_page.qualification_fields.qts, next_page: publish_courses_new_funding_type_page)
    course_creation_params = select_apprenticeship(course_creation_params, next_page: publish_courses_new_study_mode_page)
    course_creation_params = select_study_mode(course_creation_params, next_page: publish_courses_new_schools_page)
    course_creation_params = select_school(course_creation_params, next_page: publish_courses_new_study_sites_page)
    course_creation_params = select_study_site(course_creation_params, next_page: publish_courses_new_student_visa_sponsorship_page)
    course_creation_params = select_visa_settings(course_creation_params)
    course_creation_params = select_sponsorship_application_deadline_required(course_creation_params)
    course_creation_params = select_sponsorship_application_deadline_date(course_creation_params, next_page: publish_courses_new_applications_open_page)
    course_creation_params = select_applications_open_from(course_creation_params, next_page: publish_courses_new_start_date_page)
    select_start_date(course_creation_params)

    save_course
  end

  def given_i_am_authenticated_as_a_provider_user_in_the_next_cycle
    given_i_am_authenticated(
      user: create(
        :user,
        providers: [
          create(:provider, :next_recruitment_cycle, :accredited_provider, sites: [build(:site), build(:site)], study_sites: [build(:site, :study_site), build(:site, :study_site)]),
        ],
      ),
    )
  end

  def and_the_visa_sponsor_deadline_feature_flag_is_on
    FeatureFlag.activate(:visa_sponsorship_deadline)
  end

  def when_i_visit_the_courses_page
    publish_provider_courses_index_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year,
    )
  end

  def provider
    @provider ||= @current_user.providers.first
  end

  def course
    @course ||= provider.courses.first
  end

  def recruitment_cycle
    @recruitment_cycle ||= provider.recruitment_cycle
  end

  def sites
    @sites ||= provider.sites.sort_by(&:location_name)
  end

  def study_sites
    @study_sites ||= provider.study_sites.sort_by(&:location_name)
  end

  def and_i_click_on_add_course
    publish_provider_courses_index_page.add_course.click
  end

  def then_i_see_the_new_course_level_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/courses/level/new")
  end

  def select_level(course_creation_params, level:, level_selection:, next_page:,
                   is_send_value: "false", is_send: publish_courses_new_level_page.send_fields.is_send_false)
    course_creation_params[:level] = level
    course_creation_params[:is_send] = is_send_value

    level_selection.click
    is_send.click

    publish_courses_new_level_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def primary_subject
    @primary_subject ||= find(:primary_subject, :primary)
  end

  def course_subject(level)
    primary_subject if level == "primary"
  end

  def select_subjects(course_creation_params, level:, next_page:)
    course_creation_params[:level] = level
    course_subject = course_subject(level)
    course_creation_params[:subjects_ids] = [course_subject.id.to_s]
    course_creation_params[:master_subject_id] = course_subject.id.to_s
    course_creation_params[:campaign_name] = ""

    publish_courses_new_subjects_page.choose(course_subject.subject_name)
    publish_courses_new_subjects_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_age_range(course_creation_params, next_page:)
    course_creation_params[:age_range_in_years] = "5_to_11"

    publish_courses_new_age_range_page.age_range_fields.five_to_eleven.click
    publish_courses_new_age_range_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_outcome(course_creation_params, qualification:, qualification_selection:, next_page:)
    course_creation_params[:qualification] = qualification

    qualification_selection.click
    publish_courses_new_outcome_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_apprenticeship(course_creation_params, next_page:)
    course_creation_params[:funding] = "fee"

    publish_courses_new_apprenticeship_page.checkbox_no.click
    publish_courses_new_apprenticeship_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_apprenticeship_funding_type(course_creation_params, next_page:)
    course_creation_params[:funding_type] = "fee"

    publish_courses_new_apprenticeship_page.checkbox_no.click
    publish_courses_new_apprenticeship_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_study_mode(course_creation_params, next_page:)
    course_creation_params[:study_mode] = %w[full_time]

    publish_courses_new_study_mode_page.study_mode_fields.full_time.click
    publish_courses_new_study_mode_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_visa_settings(course_creation_params)
    course_creation_params[:can_sponsor_student_visa] = "true"

    publish_courses_new_student_visa_sponsorship_page.yes.click
    publish_courses_new_student_visa_sponsorship_page.continue.click

    expect_path_and_params(
      expected_path: new_publish_provider_recruitment_cycle_courses_visa_sponsorship_application_deadline_required_path(
        provider_code: @provider.provider_code,
        recruitment_cycle_year: @provider.recruitment_cycle_year,
      ),
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_sponsorship_application_deadline_required(course_creation_params)
    course_creation_params[:visa_sponsorship_application_deadline_required] = "true"
    choose "Yes"
    click_on "Continue"

    expect_path_and_params(
      expected_path: new_publish_provider_recruitment_cycle_courses_visa_sponsorship_application_deadline_date_path(
        provider_code: @provider.provider_code,
        recruitment_cycle_year: @provider.recruitment_cycle_year,
      ),
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_sponsorship_application_deadline_date(course_creation_params, next_page:)
    year = @provider.recruitment_cycle_year
    course_creation_params[:'visa_sponsorship_application_deadline_at(1i)'] = year.to_s
    course_creation_params[:'visa_sponsorship_application_deadline_at(2i)'] = "9"
    course_creation_params[:'visa_sponsorship_application_deadline_at(3i)'] = "1"

    fill_in "Year", with: year
    fill_in "Month", with: 9
    fill_in "Day", with: 1

    click_on "Continue"

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_sponsorship_application_deadline_required(course_creation_params, next_page:)
    course_creation_params[:visa_sponsorship_application_deadline_required] = 'true'

    publish_courses_new_visa_sponsorship_application_deadline_required_page.yes.click
    publish_courses_new_visa_sponsorship_application_deadline_required_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params
    )
    course_creation_params
  end

  def select_sponsorship_application_deadline_date(course_creation_params, next_page:)
    course_creation_params[:'visa_sponsorship_application_deadline_at(1i)'] = '2026'
    course_creation_params[:'visa_sponsorship_application_deadline_at(2i)'] = '9'
    course_creation_params[:'visa_sponsorship_application_deadline_at(3i)'] = '1'

    publish_courses_new_visa_sponsorship_application_deadline_date_page.day.set(1)
    publish_courses_new_visa_sponsorship_application_deadline_date_page.month.set(9)
    publish_courses_new_visa_sponsorship_application_deadline_date_page.year.set(recruitment_cycle.application_end_date.year)
    publish_courses_new_visa_sponsorship_application_deadline_date_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params
    )

    course_creation_params
  end

  def select_school(course_creation_params, next_page:)
    course_creation_params[:sites_ids] = [sites.first.id.to_s, sites.second.id.to_s]

    publish_courses_new_schools_page.check(sites.first.location_name)
    publish_courses_new_schools_page.check(sites.second.location_name)

    publish_courses_new_schools_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_study_site(course_creation_params, next_page:)
    course_creation_params[:study_sites_ids] = [study_sites.first.id.to_s, study_sites.second.id.to_s]

    publish_courses_new_study_sites_page.check(study_sites.first.location_name)
    publish_courses_new_study_sites_page.check(study_sites.second.location_name)

    publish_courses_new_study_sites_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_applications_open_from(course_creation_params, next_page:)
    course_creation_params[:applications_open_from] = recruitment_cycle.application_start_date.iso8601

    publish_courses_new_applications_open_page.applications_open_field.click
    publish_courses_new_applications_open_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_start_date(course_creation_params)
    course_creation_params[:start_date] = "January #{recruitment_cycle.year.to_i + 1}"

    publish_courses_new_start_date_page.choose "January #{recruitment_cycle.year.to_i + 1}"
    publish_courses_new_start_date_page.continue.click

    # Addressable, the gem site-prism relies on, cannot match parameters containing a +
    # https://github.com/sporkmonger/addressable/issues/142
    # Addressable::Template.new('/a{?query*}').match(Addressable::URI.parse('/a?a=b+b')) == false
    # Addressable::Template.new('/a{?query*}').match(Addressable::URI.parse('/a?a=b')) == true
    # To work around this - we need to manually match the URL and query params for this request
    expect(page).to have_current_path(
      confirmation_publish_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year), ignore_query: true
    )

    current_query_string = current_url.match('\?(.*)$').captures.first
    url_params = { course: course_creation_params }

    query = Rack::Utils.parse_nested_query(current_query_string).deep_symbolize_keys

    expect(query).to match(url_params)
  end

  def save_course
    expect { publish_course_confirmation_page.save_button.click }.to change { provider.courses.reload.count }.from(0).to(1)

    expect(publish_provider_courses_index_page).to be_displayed
    expect(publish_provider_courses_index_page.success_summary).to have_content("Your course has been created")
  end
end
