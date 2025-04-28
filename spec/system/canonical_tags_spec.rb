# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Canonical tags" do
  before do
    given_i_have_courses
    and_i_visit_the_home_page
  end

  describe "Canonical tags on Find pages", service: :find do
    scenario "without query params" do
      then_the_page_contains_canonical_tags_with_no_query_params
    end

    scenario "with query parameters" do
      and_i_select_the_primary_courses
      then_the_page_contains_canonical_tags_without_query_params
    end

    scenario "when visiting a course" do
      when_i_visit_the_course_page
      then_the_page_contains_canonical_tags_for_a_course
    end

    scenario "when visiting a course and selecting an anchor tag" do
      when_i_visit_the_course_page
      and_i_click_an_anchor_tag
      then_the_page_contains_canonical_tags_for_a_course
    end
  end

  describe "Canonical tags on Publish pages", service: :publish do
    scenario "Publish page contains canonical tags" do
      and_i_visit_the_publish_page
      then_the_publish_page_contains_canonical_tags
    end
  end

  def when_i_visit_the_course_page
    visit find_course_path(
      provider_code: @mathematics_course.provider.provider_code,
      course_code: @mathematics_course.course_code,
    )
  end

  def given_i_have_courses
    provider = create(:provider)
    @mathematics_course = create(:course, :published_postgraduate, :secondary, provider:, name: "Mathematics", subjects: [find_or_create(:secondary_subject, :mathematics)])
  end

  def and_i_visit_the_home_page
    visit "/"
  end

  def and_i_visit_the_publish_page
    visit "/sign-in/"
  end

  def and_i_select_the_primary_courses
    select "Primary", from: "Subject"
    click_link_or_button "Search"
  end

  def and_i_click_an_anchor_tag
    click_link_or_button "Where you will train"
  end

  def then_the_page_contains_canonical_tags_for_a_course
    canonical_url = "http://find.localhost/course/#{@mathematics_course.provider.provider_code}/#{@mathematics_course.course_code}/"

    link_tag = page.find("link[rel='canonical']", visible: :all)
    expect(link_tag[:href]).to eq(canonical_url)

    og_url_tag = page.find("meta[property='og:url']", visible: :all)
    expect(og_url_tag[:content]).to eq(canonical_url)
  end

  def then_the_page_contains_canonical_tags_with_no_query_params
    expect(page).to have_css("link[rel='canonical'][href='http://find.localhost/']", visible: :all)
    expect(page).to have_css("meta[property='og:url'][content='http://find.localhost/']", visible: :all)
  end

  def then_the_page_contains_canonical_tags_without_query_params
    expect(page).to have_css("link[rel='canonical'][href='http://find.localhost/results/']", visible: :all)
    expect(page).to have_css("meta[property='og:url'][content='http://find.localhost/results/']", visible: :all)
  end

  def then_the_publish_page_contains_canonical_tags
    expect(page).to have_css("link[rel='canonical'][href='http://publish.localhost/sign-in/']", visible: :all)
    expect(page).to have_css("meta[property='og:url'][content='http://publish.localhost/sign-in/']", visible: :all)
  end
end
