# frozen_string_literal: true

require "rails_helper"

feature "Course show" do
  describe "published course" do
    scenario "i can view the course basic details" do
      given_i_am_authenticated_as_a_provider_user
      and_there_is_a_published_course
      when_i_visit_the_course_details_page
      then_i_see_the_primary_course_basic_details
      and_there_are_change_links
      and_i_do_not_see_engineers_teach_physics_row
    end

    context "Engineers Teach Physics course" do
      scenario "i can view the course basic details" do
        given_i_am_authenticated_as_a_provider_user
        and_there_is_a_published_physics_course
        when_i_visit_the_course_details_page
        then_i_see_the_secondary_course_basic_details
        and_i_see_engineers_teach_physics_row
      end
    end

    context "when cycle is 2025 and the course is published" do
      scenario "i can see the correct change links", travel: find_closes(2025) do
        given_a_next_recruitment_cycle_exists
        and_i_am_authenticated_as_a_provider_user
        and_rollover_has_not_started_yet
        and_there_is_a_published_course
        when_i_visit_the_course_details_page
        then_i_see_the_correct_change_links
      end
    end

    context "when it is during the 2026 schools migration" do
      scenario "i can see the correct change links with schools review", travel: find_closes(2025) do
        given_a_next_recruitment_cycle_exists
        and_i_am_authenticated_as_a_provider_user_for_next_cycle
        and_there_is_a_scheduled_course
        when_i_visit_the_course_details_page
        then_i_see_the_change_links_without_schools
        and_i_see_review_schools_link
      end
    end

    context "when schools are not reviewed or validated" do
      scenario "i can see the correct change links with schools review", travel: mid_cycle(2025) do
        given_a_next_recruitment_cycle_exists
        and_i_am_authenticated_as_a_provider_user_for_next_cycle
        and_there_is_a_published_course_with_unvalidated_schools
        when_i_visit_the_course_details_page
        then_i_see_the_change_links_without_schools
        and_i_see_review_schools_link
      end
    end
  end

  context "when the school migration period 2025 is active and schools are validated" do
    scenario "i can see the correct change links", travel: 1.day.before(find_closes(2025)) do
      given_a_next_recruitment_cycle_exists
      and_i_am_authenticated_as_a_provider_user_for_next_cycle
      and_the_new_cycle_has_started
      and_there_is_a_draft_course
      when_i_visit_the_course_details_page
      then_i_see_the_draft_course_change_links_with_start_date
      and_i_see_review_schools_link
    end
  end

  context "withdrawn course" do
    scenario "i can view the course basic details" do
      given_i_am_authenticated_as_a_provider_user
      and_there_is_a_withdrawn_course
      when_i_visit_the_course_details_page
      then_i_see_the_primary_course_basic_details
      and_there_is_no_change_links
      and_i_do_not_see_engineers_teach_physics_row
    end
  end

private

  def and_there_are_change_links
    expect(page.find_all(".govuk-summary-list__actions a").all? { |actions| actions.text.include?("Change ") }).to be(true)
  end

  def and_there_is_no_change_links
    expect(page.find_all(".govuk-summary-list__actions a").any?).to be(false)
  end

  def given_a_next_recruitment_cycle_exists
    @next_recruitment_cycle = find_or_create(:recruitment_cycle, :next)
  end

  def and_rollover_has_not_started_yet
    Timecop.travel(1.day.before(@next_recruitment_cycle.available_for_support_users_from))
  end

  def and_the_new_cycle_has_started
    Timecop.travel(1.day.after(find_opens(2026)))
    # Changing the time will log the user out
    # /lib/publish/authentication/user_session.rb:34
    visit_auth_sign_in_page
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end
  alias_method :and_i_am_authenticated_as_a_provider_user, :given_i_am_authenticated_as_a_provider_user

  def and_i_am_authenticated_as_a_provider_user_for_next_cycle
    given_i_am_authenticated(
      user: create(
        :user,
        providers: [create(:provider, recruitment_cycle: @next_recruitment_cycle)],
      ),
    )
  end

  def and_there_is_a_published_physics_course
    given_a_course_exists(:with_accrediting_provider, :secondary, schools_validated: true, master_subject_id: 29, funding: "apprenticeship", campaign_name: "engineers_teach_physics", start_date: Date.parse("2022 January"), enrichments: [build(:course_enrichment, :published)], subjects: [find_or_create(:secondary_subject, :physics)])
    given_a_site_exists(:full_time_vacancies, :findable)
  end

  def and_there_is_a_withdrawn_course
    given_a_course_exists(:with_accrediting_provider, start_date: Date.parse("2022 January"), funding: "apprenticeship", enrichments: [build(:course_enrichment, :withdrawn)])
    given_a_site_exists(:full_time_vacancies, :findable)
  end

  def and_there_is_a_published_course_with_unvalidated_schools
    given_a_course_exists(:with_accrediting_provider, schools_validated: false, funding: "apprenticeship", start_date: Date.parse("2022 January"), enrichments: [build(:course_enrichment, :published)])
    given_a_site_exists(:full_time_vacancies, :findable)
  end

  def and_there_is_a_draft_course
    given_a_course_exists(:with_accrediting_provider, funding: "apprenticeship", start_date: Date.parse("2022 January"), enrichments: [build(:course_enrichment, :draft)])
    given_a_site_exists(:full_time_vacancies, :findable)
  end

  def and_there_is_a_published_course
    given_a_course_exists(:with_accrediting_provider, funding: "apprenticeship", start_date: Date.parse("2022 January"), enrichments: [build(:course_enrichment, :published)])
    given_a_site_exists(:full_time_vacancies, :findable)
  end

  alias_method :and_there_is_a_scheduled_course, :and_there_is_a_published_course

  def when_i_visit_the_course_details_page
    publish_provider_courses_details_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def and_i_do_not_see_engineers_teach_physics_row
    expect(publish_provider_courses_details_page).not_to have_engineers_teach_physics
  end

  def and_i_see_engineers_teach_physics_row
    expect(publish_provider_courses_details_page).to have_engineers_teach_physics
    expect(publish_provider_courses_details_page.engineers_teach_physics.key).to have_content("Engineers Teach Physics")
    expect(publish_provider_courses_details_page.engineers_teach_physics.value).to have_content("Yes")
  end

  def and_i_see_the_common_course_basic_details
    expect(publish_provider_courses_details_page.title).to have_content(
      "#{course.name} (#{course.course_code})",
    )

    expect(publish_provider_courses_details_page).to have_course_button_panel

    expect(publish_provider_courses_details_page.subjects).to have_content(
      course.subjects.sort.join,
    )
    expect(publish_provider_courses_details_page.outcome).to have_content(
      "QTS with PGCE",
    )
    expect(publish_provider_courses_details_page.study_mode).to have_content(
      "Full time",
    )
    expect(publish_provider_courses_details_page.start_date).to have_content(
      "January 2022",
    )
    expect(publish_provider_courses_details_page.start_date).to have_content(
      "Academic year 2021 to 2022",
    )

    expect(publish_provider_courses_details_page.schools).to have_content(
      course.sites.first.location_name,
    )

    expect(publish_provider_courses_details_page.funding).to have_content(
      "Salary (apprenticeship)",
    )
    expect(publish_provider_courses_details_page.accredited_provider).to have_content(
      course.accrediting_provider.provider_name,
    )
    expect(publish_provider_courses_details_page.is_send).to have_content(
      "No",
    )
  end

  def then_i_see_the_secondary_course_basic_details
    expect(publish_provider_courses_details_page.age_range).to have_content(
      "11 to 18",
    )

    expect(publish_provider_courses_details_page.level).to have_content(
      "Secondary",
    )
    and_i_see_the_common_course_basic_details
  end

  def then_i_see_the_primary_course_basic_details
    expect(publish_provider_courses_details_page.age_range).to have_content(
      "3 to 7",
    )

    expect(publish_provider_courses_details_page.level).to have_content(
      "Primary",
    )
    and_i_see_the_common_course_basic_details
  end

  def then_i_see_the_correct_change_links
    expect(publish_provider_courses_details_page.change_link_texts).to contain_exactly("subjects", "age range", "outcome", "if full or part time", "schools", "can sponsor skilled_worker visa")
  end

  def and_i_see_review_schools_link
    expect(publish_provider_courses_details_page).to have_link("Review the schools for this course")
  end

  def then_i_see_the_draft_course_change_links_with_start_date
    expect(publish_provider_courses_details_page.change_link_texts).to contain_exactly("subjects",
                                                                                       "age range",
                                                                                       "outcome",
                                                                                       "if full or part time",
                                                                                       "can sponsor skilled_worker visa",
                                                                                       "funding type",
                                                                                       "accredited provider",
                                                                                       "date course starts")
  end

  def then_i_see_the_change_links_without_schools
    expect(
      publish_provider_courses_details_page.change_link_texts,
    ).to contain_exactly(
      "subjects",
      "age range",
      "outcome",
      "if full or part time",
      "can sponsor skilled_worker visa",
      "date course starts",
    )
  end

  def then_i_see_the_correct_change_links_for_the_next_cycle
    expect(
      publish_provider_courses_details_page.change_link_texts,
    ).to contain_exactly(
      "subjects",
      "age range",
      "outcome",
      "if full or part time",
      "can sponsor skilled_worker visa",
      "date course starts",
      "schools",
    )
  end

  def provider
    @current_user.providers.first
  end
end
