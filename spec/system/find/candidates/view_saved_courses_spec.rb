require "rails_helper"

RSpec.describe "Viewing my saved courses", service: :find do
  before do
    FeatureFlag.activate(:candidate_accounts)
    FeatureFlag.activate(:bursaries_and_scholarships_announced)
    CandidateAuthHelper.mock_auth
    given_a_published_course_exists
  end

  scenario "A candidate can view their saved courses" do
    when_i_log_in_as_a_candidate
    and_i_have_saved_courses

    then_i_visit_my_saved_courses

    then_i_view_my_saved_courses
    then_the_back_link_takes_me_back_to_the_saved_courses_page
  end

  scenario "A candidate can view the saved courses page with no saved courses" do
    when_i_log_in_as_a_candidate
    then_i_visit_my_saved_courses

    then_i_see_no_saved_courses_message
  end

  context "saved status tag across cycle stages" do
    scenario "Apply has closed but old Find courses are still there shows Closed" do
      given_a_published_course_exists
      Timecop.travel(1.day.after(apply_deadline))

      when_i_log_in_as_a_candidate
      and_i_have_saved_courses
      then_i_visit_my_saved_courses

      then_i_should_see_in_first_saved_course_row("Not accepting applications")
    end

    scenario "Find has re-opened but Apply hasn't opened yet shows Not yet open" do
      given_a_published_course_exists
      Timecop.travel(1.day.after(find_opens))

      when_i_log_in_as_a_candidate
      and_i_have_saved_courses
      then_i_visit_my_saved_courses

      then_i_should_see_in_first_saved_course_row("Not yet open")
    end

    scenario "Both Find and Apply are open, provider closed course early shows Closed" do
      given_a_published_course_exists
      Timecop.travel(1.day.after(apply_opens))
      @course.update!(application_status: :closed)

      when_i_log_in_as_a_candidate
      and_i_have_saved_courses
      then_i_visit_my_saved_courses

      then_i_should_see_in_first_saved_course_row("Not accepting applications")
    end

    scenario "Withdrawn course shows Withdrawn" do
      given_a_withdrawn_course_exists
      Timecop.travel(1.day.after(apply_opens))

      when_i_log_in_as_a_candidate
      and_i_have_saved_courses
      then_i_visit_my_saved_courses

      then_i_should_see_in_first_saved_course_row("Withdrawn")
    end
  end

  context "sorting and location" do
    scenario "default sort is most recently saved" do
      when_i_log_in_as_a_candidate
      and_i_have_multiple_saved_courses

      then_i_visit_my_saved_courses

      then_i_see_courses_ordered_newest_first
      and_most_recently_saved_is_the_active_sort
      and_distance_sort_is_not_visible
    end

    scenario "searching by location shows distance and auto-sorts by distance" do
      when_i_log_in_as_a_candidate
      and_i_have_courses_at_different_locations

      then_i_visit_my_saved_courses
      and_i_search_for_london

      then_i_see_courses_ordered_by_distance
      and_distance_is_the_active_sort
      and_i_see_distance_information
    end

    scenario "sorting by most recently saved via link" do
      when_i_log_in_as_a_candidate
      and_i_have_courses_at_different_locations

      then_i_visit_my_saved_courses
      and_i_search_for_london
      and_i_click_sort_by_most_recently_saved

      then_i_see_courses_ordered_newest_first_with_location
      and_most_recently_saved_is_the_active_sort
      and_distance_sort_is_visible
    end

    scenario "sorting by lowest fee for UK citizens" do
      when_i_log_in_as_a_candidate
      and_i_have_courses_with_different_fees

      then_i_visit_my_saved_courses
      and_i_click_sort_by_lowest_fee_uk

      then_i_see_courses_ordered_by_uk_fee
      and_lowest_fee_uk_is_the_active_sort
      and_i_see_fee_information
    end

    scenario "sorting by lowest fee for non-UK citizens" do
      when_i_log_in_as_a_candidate
      and_i_have_courses_with_different_fees

      then_i_visit_my_saved_courses
      and_i_click_sort_by_lowest_fee_intl

      then_i_see_courses_ordered_by_intl_fee
      and_lowest_fee_intl_is_the_active_sort
      and_i_see_fee_information
    end

    scenario "placement hint shown when no location searched" do
      when_i_log_in_as_a_candidate
      and_i_have_saved_courses

      then_i_visit_my_saved_courses

      then_i_see_placement_hint
    end

    scenario "searching by location filters out courses outside the default radius" do
      when_i_log_in_as_a_candidate
      and_i_have_courses_in_london_and_cambridge

      then_i_visit_my_saved_courses
      and_i_search_for_london

      then_i_see_only_london_course
      and_i_do_not_see_cambridge_course
    end
  end

  # --- Shared steps ---

  def when_i_log_in_as_a_candidate
    visit "/"
    click_link_or_button "Sign in"
    expect(page).to have_content("You have been successfully signed in.")
  end

  def then_i_visit_my_saved_courses
    click_link_or_button "Saved courses"
  end

  def and_i_have_saved_courses
    candidate = Candidate.first
    @saved_courses = create(:saved_course, course: @course, candidate: candidate)
  end

  # --- Course setup helpers ---

  def given_a_published_course_exists
    physics = create(:secondary_subject, :physics, bursary_amount: 20_000, scholarship: 22_000)

    @course = create(
      :course,
      :with_full_time_sites,
      :secondary,
      :with_special_education_needs,
      :published,
      :open,
      name: "Art and design (SEND)",
      course_code: "F314",
      provider: build(:provider),
      subjects: [physics],
      master_subject_id: physics.id,
      enrichments: [create(:course_enrichment, :published, fee_uk_eu: 9535, fee_international: 17_500)],
    )
  end

  def given_a_withdrawn_course_exists
    @course = create(
      :course,
      :with_full_time_sites,
      :secondary,
      :with_special_education_needs,
      :withdrawn,
      name: "Art and design (SEND)",
      course_code: "F315",
      provider: build(:provider),
      subjects: [find_or_create(:secondary_subject, :art_and_design)],
    )
  end

  def and_i_have_multiple_saved_courses
    candidate = Candidate.first
    london = build(:location, :london)

    @old_course = create(
      :course,
      :published,
      :open,
      name: "Old Course",
      course_code: "OLD1",
      provider: create(:provider, provider_name: "Alpha Provider"),
      site_statuses: [create(:site_status, :findable, site: create(:site, latitude: london.latitude, longitude: london.longitude))],
    )

    @new_course = create(
      :course,
      :published,
      :open,
      name: "New Course",
      course_code: "NEW1",
      provider: create(:provider, provider_name: "Beta Provider"),
      site_statuses: [create(:site_status, :findable, site: create(:site, latitude: london.latitude, longitude: london.longitude))],
    )

    create(:saved_course, course: @old_course, candidate: candidate, created_at: 2.days.ago)
    create(:saved_course, course: @new_course, candidate: candidate, created_at: 1.hour.ago)
  end

  def and_i_have_courses_at_different_locations
    candidate = Candidate.first
    london = build(:location, :london)
    lewisham = build(:location, :lewisham)

    @london_course = create(
      :course,
      :published,
      :open,
      name: "London Course",
      course_code: "LON1",
      provider: create(:provider, provider_name: "London University"),
      site_statuses: [create(:site_status, :findable, site: create(:site, latitude: london.latitude, longitude: london.longitude))],
    )

    @lewisham_course = create(
      :course,
      :published,
      :open,
      name: "Lewisham Course",
      course_code: "LEW1",
      provider: create(:provider, provider_name: "Lewisham University"),
      site_statuses: [create(:site_status, :findable, site: create(:site, latitude: lewisham.latitude, longitude: lewisham.longitude))],
    )

    create(:saved_course, course: @lewisham_course, candidate: candidate, created_at: 1.hour.ago)
    create(:saved_course, course: @london_course, candidate: candidate, created_at: 2.days.ago)
  end

  def and_i_have_courses_in_london_and_cambridge
    candidate = Candidate.first
    london = build(:location, :london)
    cambridge = build(:location, :cambridge)

    @london_course = create(
      :course,
      :published,
      :open,
      name: "London Course",
      course_code: "LON1",
      provider: create(:provider, provider_name: "London University"),
      site_statuses: [create(:site_status, :findable, site: create(:site, latitude: london.latitude, longitude: london.longitude))],
    )

    @cambridge_course = create(
      :course,
      :published,
      :open,
      name: "Cambridge Course",
      course_code: "CAM1",
      provider: create(:provider, provider_name: "Cambridge University"),
      site_statuses: [create(:site_status, :findable, site: create(:site, latitude: cambridge.latitude, longitude: cambridge.longitude))],
    )

    create(:saved_course, course: @cambridge_course, candidate: candidate, created_at: 1.hour.ago)
    create(:saved_course, course: @london_course, candidate: candidate, created_at: 2.days.ago)
  end

  def and_i_have_courses_with_different_fees
    candidate = Candidate.first

    @cheap_course = create(
      :course,
      :published,
      :open,
      :with_full_time_sites,
      :fee,
      name: "Cheap Course",
      course_code: "CHP1",
      provider: create(:provider, provider_name: "Cheap Provider"),
      enrichments: [build(:course_enrichment, :published, fee_uk_eu: 5000, fee_international: 10_000)],
    )

    @expensive_course = create(
      :course,
      :published,
      :open,
      :with_full_time_sites,
      :fee,
      name: "Expensive Course",
      course_code: "EXP1",
      provider: create(:provider, provider_name: "Expensive Provider"),
      enrichments: [build(:course_enrichment, :published, fee_uk_eu: 9000, fee_international: 18_000)],
    )

    create(:saved_course, course: @expensive_course, candidate: candidate, created_at: 1.hour.ago)
    create(:saved_course, course: @cheap_course, candidate: candidate, created_at: 2.days.ago)
  end

  # --- Location search ---

  def and_i_search_for_london
    stub_london_geocode

    fill_in "City, town or postcode", with: "London"
    click_link_or_button "Add location"
  end

  def stub_london_geocode
    stub_request(
      :get,
      "https://maps.googleapis.com/maps/api/geocode/json?address=London&components=country:UK&key=replace_me&language=en",
    ).to_return(
      status: 200,
      body: file_fixture("google_old_places_api_client/geocode/london.json").read,
      headers: { "Content-Type" => "application/json" },
    )
  end

  # --- Sort link actions ---

  def and_i_click_sort_by_most_recently_saved
    click_link_or_button "Most recently saved"
  end

  def and_i_click_sort_by_lowest_fee_uk
    click_link_or_button "Lowest fee for UK citizens"
  end

  def and_i_click_sort_by_lowest_fee_intl
    click_link_or_button "Lowest fee for non-UK citizens"
  end

  # --- Sort ordering assertions ---

  def then_i_see_courses_ordered_newest_first
    rows = saved_course_names
    expect(rows).to eq(["New Course", "Old Course"])
  end

  def then_i_see_courses_ordered_by_distance
    rows = saved_course_names
    expect(rows).to eq(["London Course", "Lewisham Course"])
  end

  def then_i_see_courses_ordered_newest_first_with_location
    rows = saved_course_names
    expect(rows).to eq(["Lewisham Course", "London Course"])
  end

  def then_i_see_courses_ordered_by_uk_fee
    rows = saved_course_names
    expect(rows).to eq(["Cheap Course", "Expensive Course"])
  end

  def then_i_see_courses_ordered_by_intl_fee
    rows = saved_course_names
    expect(rows).to eq(["Cheap Course", "Expensive Course"])
  end

  # --- Sort link active/inactive assertions ---

  def and_most_recently_saved_is_the_active_sort
    within(sort_bar) do
      expect(page).to have_css("strong", text: "Most recently saved")
      expect(page).not_to have_link("Most recently saved")
    end
  end

  def and_distance_is_the_active_sort
    within(sort_bar) do
      expect(page).to have_css("strong", text: "Distance")
      expect(page).not_to have_link("Distance")
    end
  end

  def and_lowest_fee_uk_is_the_active_sort
    within(sort_bar) do
      expect(page).to have_css("strong", text: "Lowest fee for UK citizens")
      expect(page).not_to have_link("Lowest fee for UK citizens")
    end
  end

  def and_lowest_fee_intl_is_the_active_sort
    within(sort_bar) do
      expect(page).to have_css("strong", text: "Lowest fee for non-UK citizens")
      expect(page).not_to have_link("Lowest fee for non-UK citizens")
    end
  end

  def and_distance_sort_is_not_visible
    within(sort_bar) do
      expect(page).not_to have_content("Distance")
    end
  end

  def and_distance_sort_is_visible
    within(sort_bar) do
      expect(page).to have_link("Distance")
    end
  end

  # --- Distance info assertions ---

  def and_i_see_distance_information
    expect(page).to have_content("Nearest placement school")
    expect(page).to have_content("from London")
  end

  def then_i_see_placement_hint
    expect(page).to have_content("Add a location to see the nearest potential placement school")
  end

  def then_i_see_only_london_course
    expect(page).to have_content("London Course")
  end

  def and_i_do_not_see_cambridge_course
    expect(page).not_to have_content("Cambridge Course")
  end

  def and_i_see_fee_information
    expect(page).to have_content("Fee or salary")
    expect(page).to have_content("fee for UK citizens")
    expect(page).to have_content("fee for Non-UK citizens")
  end

  # --- Existing scenario assertions ---

  def then_i_see_no_saved_courses_message
    expect(page).to have_content("You have no saved courses")
    expect(page).to have_link("Find a course", href: find_root_path)
    expect(page).to have_content("and start saving courses you may want to review and apply for later.")
  end

  def then_i_view_my_saved_courses
    within_first_saved_course_row do
      expect(page).to have_content(@course.provider.provider_name)
      expect(page).to have_content(@course.name)
      expect(page).to have_content(@course.course_code)
      expect(page).to have_content("Delete")
      expect(page).to have_content("Fee or salary")

      expect(page).to have_link(
        @course.provider.provider_name,
        href: find_course_path(
          provider_code: @course.provider_code,
          course_code: @course.course_code,
        ),
      )
    end
  end

  def then_the_back_link_takes_me_back_to_the_saved_courses_page
    click_link_or_button @course.provider.provider_name
    expect(page).to have_link("Back to saved courses", href: find_candidate_saved_courses_path)
  end

  def then_i_should_see_in_first_saved_course_row(text)
    within_first_saved_course_row do
      expect(page).to have_content(text)
    end
  end

  # --- Helpers ---

  def within_first_saved_course_row(&block)
    within(all(".govuk-summary-card").first, &block)
  end

  def saved_course_names
    all(".govuk-summary-card__title a").map do |link|
      link.native.children.select(&:text?).last.text.split("(").first.strip
    end
  end

  def sort_bar
    page.find("p.govuk-body", text: "Sort by:")
  end
end
