require "rails_helper"

feature "new course" do
  scenario "creates the correct course" do
    # This is intended to be a test which will go through the entire flow
    # and ensure that the correct page gets displayed at the end
    # with the correct course being created
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_courses_page
    and_i_click_on_add_course
    then_i_can_create_the_course
  end

private

  def then_i_can_create_the_course
    expect(new_level_page).to be_displayed
    course_creation_params = select_level({}, level: "primary", level_selection: new_level_page.level_fields.primary, next_page: new_subjects_page)
    course_creation_params = select_subjects(course_creation_params, level: "primary", next_page: new_age_range_page)
    course_creation_params = select_age_range(course_creation_params, next_page: new_outcome_page)
    course_creation_params = select_outcome(course_creation_params, qualification: "qts", qualification_selection: new_outcome_page.qualification_fields.qts, next_page: new_apprenticeship_page)
    course_creation_params = select_apprenticeship(course_creation_params, next_page: new_study_mode_page)
    course_creation_params = select_study_mode(course_creation_params, next_page: new_locations_page)
    course_creation_params = select_location(course_creation_params, next_page: new_applications_open_page)
    course_creation_params = select_applications_open_from(course_creation_params, next_page: new_start_date_page)
    select_start_date(course_creation_params)

    save_course
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(
      user: create(
        :user,
        providers: [
          create(:provider, :accredited_body, sites: [build(:site), build(:site)]),
        ],
      ),
    )
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

  def and_i_click_on_add_course
    publish_provider_courses_index_page.add_course.click
  end

  def then_i_see_the_new_course_level_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/courses/level/new")
  end

  def expect_page_to_be_displayed_with_query(page:, expected_query_params:)
    current_query_string = current_url.match('\?(.*)$').captures.first
    url_params = { course: expected_query_params }

    expect(page).to be_displayed

    query = Rack::Utils.parse_nested_query(current_query_string).deep_symbolize_keys

    expect(query).to match(url_params)
  end

  def select_level(course_creation_params, level:, level_selection:, next_page:)
    course_creation_params[:level] = level
    course_creation_params[:is_send] = "0"

    level_selection.click
    new_level_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def primary
    @primary ||= %i[primary primary_with_english primary_with_geography_and_history primary_with_mathematics primary_with_modern_languages primary_with_physical_education primary_with_science].sample
  end

  def primary_subject
    @primary_subject ||= find(:primary_subject, primary)
  end

  def course_subject(level)
    if level == "primary"
      primary_subject
    end
  end

  def select_subjects(course_creation_params, level:, next_page:)
    course_creation_params[:level] = level
    course_subject = course_subject(level)
    course_creation_params[:subjects_ids] = [course_subject.id.to_s]

    new_subjects_page.subjects_fields.select(course_subject.subject_name)
    new_subjects_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_age_range(course_creation_params, next_page:)
    course_creation_params[:age_range_in_years] = "5_to_11"

    choose("course_age_range_in_years_5_to_11")
    click_on "Continue"

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_outcome(course_creation_params, qualification:, qualification_selection:, next_page:)
    course_creation_params[:qualification] = qualification

    qualification_selection.click
    new_outcome_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_apprenticeship(course_creation_params, next_page:)
    course_creation_params[:funding_type] = "fee"

    new_apprenticeship_page.no.click
    new_apprenticeship_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_study_mode(course_creation_params, next_page:)
    course_creation_params[:study_mode] = "full_time"

    new_study_mode_page.study_mode_fields.full_time.click
    new_study_mode_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_location(course_creation_params, next_page:)
    course_creation_params[:sites_ids] = [sites.first.id.to_s, sites.second.id.to_s]

    new_locations_page.check(sites.first.location_name)
    new_locations_page.check(sites.second.location_name)

    new_locations_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_applications_open_from(course_creation_params, next_page:)
    course_creation_params[:applications_open_from] = recruitment_cycle.application_start_date.iso8601

    new_applications_open_page.applications_open_field.click
    new_applications_open_page.continue.click

    expect_page_to_be_displayed_with_query(
      page: next_page,
      expected_query_params: course_creation_params,
    )

    course_creation_params
  end

  def select_start_date(course_creation_params)
    course_creation_params[:start_date] = "September #{recruitment_cycle.year}"

    new_start_date_page.select "September #{recruitment_cycle.year}"
    new_start_date_page.continue.click

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
    expect { confirmation_page.save_button.click }.to change { provider.courses.reload.count } .from(0).to(1)

    expect(publish_provider_courses_index_page).to be_displayed
    expect(publish_provider_courses_index_page.success_summary).to have_content("Your course has been created")
  end
end
