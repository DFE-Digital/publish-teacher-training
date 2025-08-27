require "rails_helper"

RSpec.describe "Viewing long form course content for where you will train", service: :find do
  before do
    given_a_published_course_exists
  end

  scenario "A user can see the Fees and financial support long from content" do
    when_i_visit_a_course
    then_i_see_the_where_you_will_train_section
    then_i_see_the_long_form_content
  end

  def when_i_visit_a_course
    visit find_results_path
    click_on_first_course
  end

  def click_on_first_course
    page.first(".app-search-results").first("a").click
  end

  def then_i_see_the_where_you_will_train_section
    expect(page).to have_content("Where you will train")
  end

  def then_i_see_the_long_form_content
    enrichment = @course.enrichments.first
    expect(page).to have_content(enrichment.placement_selection_criteria)
    expect(page).to have_content(enrichment.duration_per_school)
    expect(page).to have_content(enrichment.theoretical_training_location)
    expect(page).to have_content(enrichment.theoretical_training_duration)
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
          placement_selection_criteria: "Abc criteria",
          duration_per_school: "2 weeks",
          theoretical_training_location: "London",
          theoretical_training_duration: "3 weeks",
        ),
      ],
      name: "Art and design (SEND)",
      course_code: "F314",
      provider: build(:provider, provider_name: "York university", provider_code: "RO1"),
      subjects: [find_or_create(:secondary_subject, :art_and_design)],
    )
  end
end
