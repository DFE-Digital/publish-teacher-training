require "rails_helper"

RSpec.describe "Viewing long form course content for the interview process", service: :find do
  before do
    FeatureFlag.activate(:long_form_content)
  end

  scenario "A user can see the interview process long from content when the interview location is BOTH" do
    given_a_published_course_exists
    when_i_visit_a_course
    then_i_see_the_interview_process_section
    then_i_see_the_long_form_content_for_interview_location_both
  end

  scenario "A user can see the interview process long from content when the interview location is IN PERSON" do
    given_a_published_course_exists(interview_location: "in person")
    when_i_visit_a_course
    then_i_see_the_interview_process_section
    then_i_see_the_long_form_content_for_interview_location_in_person
  end

  scenario "A user can see the interview process long from content when the interview location is ONLINE" do
    given_a_published_course_exists(interview_location: "online")
    when_i_visit_a_course
    then_i_see_the_interview_process_section
    then_i_see_the_long_form_content_for_interview_location_online
  end

  def when_i_visit_a_course
    visit find_results_path
    click_on_first_course
  end

  def click_on_first_course
    page.first(".app-search-results").first("a").click
  end

  def then_i_see_the_interview_process_section
    expect(page).to have_content("Interview process")
  end

  def then_i_see_the_long_form_content_for_interview_location_both
    enrichment = @course.enrichments.first

    expect(page).to have_content("Online interviews are available for this course")
    expect(page).to have_content("Depending on the individual circumstances")
    expect(page).to have_content(enrichment.interview_process)
  end

  def then_i_see_the_long_form_content_for_interview_location_in_person
    enrichment = @course.enrichments.first

    expect(page).not_to have_content("Online interviews are available for this course")
    expect(page).not_to have_content("Depending on the individual circumstances")
    expect(page).to have_content(enrichment.interview_process)
  end

  def then_i_see_the_long_form_content_for_interview_location_online
    enrichment = @course.enrichments.first

    expect(page).to have_content("Online interviews are available for this course")
    expect(page).not_to have_content("Depending on the individual circumstances")
    expect(page).to have_content(enrichment.interview_process)
  end

  def given_a_published_course_exists(interview_location: "both")
    @course = create(
      :course,
      :with_full_time_sites,
      :secondary,
      :with_special_education_needs,
      :published,
      :open,
      enrichments: [
        build(
          :course_enrichment,
          :published,
          :v2,
          interview_process: "The interview process is a 72 stage process",
          interview_location:,
        ),
      ],
      name: "Art and design (SEND)",
      course_code: "F314",
      provider: build(:provider, provider_name: "York university", provider_code: "RO1"),
      subjects: [find_or_create(:secondary_subject, :art_and_design)],
    )
  end
end
