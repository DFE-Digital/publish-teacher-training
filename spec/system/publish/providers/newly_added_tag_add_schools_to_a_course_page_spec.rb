require "rails_helper"

RSpec.describe "Publish - Courses: 'Newly added' tag for register import sites when selecting schools", service: :publish, travel: 1.hour.before(find_closes(2025)) do
  include DfESignInUserHelper

  let(:recruitment_cycle) { find_or_create(:recruitment_cycle, year: 2026) }
  let(:provider) { create(:provider, provider_name: "Tag Provider", recruitment_cycle:) }
  let!(:course) { create(:course, provider:) }

  let!(:site_one) do
    create(
      :site,
      provider:,
      added_via: :register_import,
      location_name: "Register Import School",
      address1: "1 Import Road",
    )
  end

  let!(:site_two) do
    create(
      :site,
      provider:,
      added_via: :publish_interface,
      location_name: "UI Added School",
      address1: "2 Publish Street",
    )
  end

  let(:user) { create(:user, providers: [provider]) }

  before do
    sign_in_system_test(user:)
  end

  scenario "shows the 'Newly added' tag on school selection checkboxes only for register import, and not after rollover" do
    when_i_visit_edit_course_schools_page

    and_i_see_checkbox_with_tag("Register Import School", "Newly added")
    and_i_see_checkbox_without_tag("UI Added School", "Newly added")

    when_i_visit_new_course_schools_page

    and_i_see_checkbox_with_tag("Register Import School", "Newly added")
    and_i_see_checkbox_without_tag("UI Added School", "Newly added")

    travel_to recruitment_cycle.rollover_end
    sign_in_system_test(user:)

    when_i_visit_edit_course_schools_page
    and_i_see_checkbox_without_tag("Register Import School", "Newly added")
    and_i_see_checkbox_without_tag("UI Added School", "Newly added")

    when_i_visit_new_course_schools_page
    and_i_see_checkbox_without_tag("Register Import School", "Newly added")
    and_i_see_checkbox_without_tag("UI Added School", "Newly added")
  end

  def when_i_visit_edit_course_schools_page
    visit schools_publish_provider_recruitment_cycle_course_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: recruitment_cycle.year,
      code: course.course_code,
    )
  end

  def when_i_visit_new_course_schools_page
    visit new_publish_provider_recruitment_cycle_courses_schools_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: recruitment_cycle.year,
    )
  end

  def and_i_see_checkbox_with_tag(school_name, tag_text)
    label = checkbox_label_for_school(school_name)

    expect(label).to have_content(tag_text), "Expected '#{tag_text}' for checkbox label '#{school_name}', but did not find it. Label text: #{label.text}"
  end

  def and_i_see_checkbox_without_tag(school_name, tag_text)
    label = checkbox_label_for_school(school_name)

    expect(label).not_to have_content(tag_text), "Expected NOT to find '#{tag_text}' for checkbox label '#{school_name}', but tag was present. Label text: #{label.text}"
  end

  def checkbox_label_for_school(text)
    page.find("label", text:)
  end
end
