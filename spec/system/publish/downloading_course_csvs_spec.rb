# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Downloading the course list as CSV" do
  let(:provider) { create(:provider, :accredited_provider) }

  before do
    given_i_am_authenticated(user: create(:user, providers: [provider]))
  end

  scenario "I am offered both downloads" do
    given_my_provider_has_courses
    when_i_visit_the_courses_page
    then_i_see_the_download_box("Download course information")
    and_it_offers("Download basic course information (CSV)", "Download the schools attached to each course (CSV)")
  end

  scenario "I download my course information" do
    given_my_provider_has_courses
    when_i_visit_the_courses_page
    when_i_follow("Download basic course information (CSV)")
    and_it_lists("Primary course", "Secondary course")
  end

  scenario "I download the schools attached to my courses" do
    given_my_provider_has_courses
    when_i_visit_the_courses_page
    when_i_follow("Download the schools attached to each course (CSV)")
    and_it_lists("Ashleigh Primary School")
  end

  scenario "the downloads ignore the filters I have applied" do
    given_my_provider_has_courses
    when_i_visit_the_courses_page
    when_i_filter_by("Secondary")
    then_i_see_only("Secondary course")

    when_i_follow("Download basic course information (CSV)")
    and_it_lists("Primary course", "Secondary course")
  end

  scenario "my courses are too alike to filter" do
    given_all_my_courses_are_identical
    when_i_visit_the_courses_page
    then_i_see_no_filters
    and_i_see_the_download_box("Download course information")
  end

  scenario "I have no courses to download" do
    when_i_visit_the_courses_page
    then_i_am_offered_no_downloads
  end

  def given_my_provider_has_courses
    primary = create(:course, :primary, provider:, accrediting_provider: nil, name: "Primary course")
    create(:course_school, course: primary, gias_school: create(:gias_school, name: "Ashleigh Primary School"))

    create(:course, :secondary, provider:, accrediting_provider: nil, name: "Secondary course")
  end

  def when_i_visit_the_courses_page(query = {})
    publish_provider_courses_index_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, **query,
    )
  end

  def when_i_filter_by(label)
    group = publish_provider_courses_index_page.filter_groups.find { |g| g.option_labels.include?(label) }.root_element
    group.find("summary").click unless group[:open]
    check(label)
    publish_provider_courses_index_page.apply_filters.click
  end

  def when_i_follow(label)
    click_link_or_button(label)
  end

  def given_all_my_courses_are_identical
    create_list(:course, 2, :without_validation, :primary, :fee, provider:, accrediting_provider: nil,
                                                                 qualification: :qts, study_mode: :full_time,
                                                                 start_date: Time.zone.local(provider.recruitment_cycle_year.to_i, 9, 1))
  end

  def then_i_see_the_download_box(heading)
    expect(publish_provider_courses_index_page.downloads.heading.text).to eq(heading)
  end
  alias_method :and_i_see_the_download_box, :then_i_see_the_download_box

  def then_i_see_no_filters
    expect(publish_provider_courses_index_page).to have_no_filter_heading
    expect(publish_provider_courses_index_page).to have_no_filter_groups
  end

  def and_it_offers(*labels)
    expect(publish_provider_courses_index_page.downloads.links.map(&:text)).to eq(labels)
  end

  def and_it_lists(*names)
    rows = CSV.parse(page.body, headers: true)

    expect(rows.map { |row| row["Course name"] } + rows.map { |row| row["Placement schools"] }).to include(*names)
  end

  def then_i_see_only(*names)
    expect(course_names).to match_array(names)
  end

  def then_i_am_offered_no_downloads
    expect(publish_provider_courses_index_page).to have_no_downloads
  end

  def course_names
    publish_provider_courses_index_page.courses.flat_map do |section|
      section.all(".app-table--courses__course-name a").map { |link| link.text.sub(/\s+\(\w+\)\z/, "") }
    end
  end
end
