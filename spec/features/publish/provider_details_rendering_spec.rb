# frozen_string_literal: true

require "rails_helper"

feature "Provider details rendering by version" do
  scenario "renders v2 provider content when latest enrichment version is 2" do
    provider = create(:provider, about_us: "About us v2", value_proposition: "Our offer v2")
    course = create(:course, :secondary, provider:)
    create(:course_enrichment, course:, status: :draft, version: 2)

    given_i_am_authenticated(user: create(:user, providers: [provider]))

    visit preview_publish_provider_recruitment_cycle_course_path(
      course.provider.provider_code,
      course.recruitment_cycle_year,
      course.course_code,
    )

    click_link_or_button(course.provider_name)

    expect(page).to have_css("#section-why-train-with-us")
    expect(page).to have_no_css("#section-about-provider")
    expect(page).to have_content("Why train with us")
    expect(page).to have_content("About us v2")
    expect(page).to have_content("Our offer v2")
  end

  scenario "renders v1 provider content when latest enrichment version is 1" do
    provider = create(:provider, train_with_us: "About us v1")
    course = create(:course, :secondary, provider:)
    create(:course_enrichment, course:, status: :draft, version: 1)

    given_i_am_authenticated(user: create(:user, providers: [provider]))

    visit preview_publish_provider_recruitment_cycle_course_path(
      course.provider.provider_code,
      course.recruitment_cycle_year,
      course.course_code,
    )

    click_link_or_button(course.provider_name)

    expect(page).to have_css("#section-about-provider")
    expect(page).to have_no_css("#section-why-train-with-us")
    expect(page).to have_content("About #{course.provider_name}")
    expect(page).to have_content("About us v1")
  end
end
