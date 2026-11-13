# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Grouped result cards", :js, service: :find do
  before do
    FeatureFlag.activate(:candidate_accounts)
    FeatureFlag.activate(:group_search_results)
    given_a_provider_has_several_maths_courses
  end

  scenario "A keyboard user reaches each course's link, then its Save" do
    when_i_visit_the_results_page

    then_the_card_lists_each_course_with_its_save_in_order
    and_each_course_link_names_the_provider
  end

  scenario "A long card fits a phone screen" do
    given_i_am_on_a_phone
    when_i_visit_the_results_page

    then_the_page_does_not_scroll_sideways
  end

  def given_a_provider_has_several_maths_courses
    @provider = create(:provider, provider_name: "North East Partnership SCITT (Physical Education and Mathematics)")
    mathematics = find_or_create(:secondary_subject, :mathematics)

    @courses = [
      ["Mathematics", :fee],
      ["Mathematics (SEND)", :fee],
      ["Mathematics with Economics", :fee],
      ["Mathematics", :salary],
      ["Mathematics (SEND)", :salary],
      ["Mathematics", :apprenticeship],
    ].each_with_index.map do |(name, funding), index|
      create(
        :course,
        :with_full_time_sites,
        :secondary,
        :published,
        :open,
        provider: @provider,
        name:,
        funding:,
        course_code: "M00#{index}",
        subjects: [mathematics],
      )
    end
  end

  def given_i_am_on_a_phone
    page.driver.with_playwright_page { |playwright_page| playwright_page.viewport_size = { width: 320, height: 640 } }
  end

  def when_i_visit_the_results_page
    visit find_results_path
  end

  def then_the_card_lists_each_course_with_its_save_in_order
    within(".app-search-results__item") do
      expect(page).to have_no_css("[tabindex]")

      course_links = all("h3 a").map { |link| link.text.squish }
      focusable = all("a, button").map { |element| element.text.squish }

      expect(course_links.size).to eq(@courses.size)
      expect(focusable).to eq(course_links.flat_map { |link| [link, "Sign in to save this course"] })
    end
  end

  def and_each_course_link_names_the_provider
    within(".app-search-results__item") do
      expect(page).to have_css("h2", text: @provider.provider_name, count: 1)
      expect(page).to have_css("h3 a", text: "at #{@provider.provider_name}", count: @courses.size)
    end
  end

  def then_the_page_does_not_scroll_sideways
    expect(page).to have_css(".app-search-result__course", count: @courses.size)
    expect(page.evaluate_script("document.documentElement.scrollWidth")).to be <= 320
  end
end
