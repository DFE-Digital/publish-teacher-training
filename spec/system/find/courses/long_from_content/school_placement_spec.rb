require "rails_helper"

RSpec.describe "Viewing long form course content for school placement", service: :find do
  before do
    given_a_published_course_exists
  end

  scenario "A user can see the Fees and financial support long from content" do
    when_i_visit_a_course
    then_i_see_the_school_placement_section
    then_i_see_the_long_form_content
  end

  def when_i_visit_a_course
    visit find_results_path
    click_on_first_course
  end

  def click_on_first_course
    page.first(".app-search-results").first("a").click
  end

  def then_i_see_the_school_placement_section
    expect(page).to have_content("What you will do on school placements")
  end

  def then_i_see_the_long_form_content
    enrichment = @course.enrichments.first
    expect(page).to have_content(enrichment.placement_school_activities)
    expect(page).to have_content(enrichment.support_and_mentorship)
  end

  def given_a_published_course_exists
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
          fee_uk_eu: 2500,
          fee_international: 3500,
          fee_schedule: "Fee schedule",
          additional_fees: "Additional fees",
          financial_support: "Support of finances",
        ),
      ],
      name: "Art and design (SEND)",
      course_code: "F314",
      provider: build(:provider, provider_name: "York university", provider_code: "RO1"),
      subjects: [find_or_create(:secondary_subject, :art_and_design)],
    )
  end
end
