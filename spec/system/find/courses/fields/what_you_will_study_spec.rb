require "rails_helper"

RSpec.describe "Viewing what you will study long form content", service: :find do
  before do
    FeatureFlag.activate(:long_form_content)
    given_a_published_course_exists
  end

  scenario "A user can see the What you will study long form content" do
    when_i_visit_a_course
    then_i_see_what_you_will_study_in_contents_list
    then_i_see_the_what_you_will_study_section
    then_i_see_the_long_form_content
  end

  def when_i_visit_a_course
    visit find_results_path
    then_i_click_on_first_course
  end

  def then_i_click_on_first_course
    page.first(".app-search-results").first("a").click
  end

  def then_i_see_what_you_will_study_in_contents_list
    expect(page).to have_css(".govuk-list li a", text: "What you will study")
  end

  def then_i_see_the_what_you_will_study_section
    expect(page).to have_content("What you will study")
  end

  def then_i_see_the_long_form_content
    enrichment = @course.enrichments.first

    expect(page).to have_content("Theoretical training activities content")
    expect(page).to have_content("Assessment methods content")
    expect(page).to have_content(enrichment.theoretical_training_activities)
    expect(page).to have_content(enrichment.assessment_methods)
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
          theoretical_training_activities: "Theoretical training activities content",
          assessment_methods: "Assessment methods content",
        ),
      ],
      name: "Art and design (SEND)",
      course_code: "F314",
      provider: build(:provider, provider_name: "York university", provider_code: "R01"),
      subjects: [find_or_create(:secondary_subject, :art_and_design)],
    )
  end
end
