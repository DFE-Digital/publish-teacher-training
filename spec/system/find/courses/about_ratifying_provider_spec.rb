require "rails_helper"

RSpec.describe "About the ratifying provider", service: :find do
  before do
    given_a_published_course_exists
  end

  scenario "A signed-in candidate can save a course", travel: Find::CycleTimetable.mid_cycle do
    when_i_view_a_course
    and_i_click_on_the_ratifying_provider_name
    then_i_see_the_content_for_about_us
    then_i_see_the_content_for_value_proposition
  end

  def when_i_view_a_course
    visit "/course/#{@course.provider.provider_code}/#{@course.course_code}"
  end

  def and_i_click_on_the_ratifying_provider_name
    click_link @accrediting_provider.provider_name
  end

  def then_i_see_the_content_for_about_us
    expect(page).to have_content("about us")
  end

  def then_i_see_the_content_for_value_proposition
    expect(page).to have_content("value proposition")
  end

  def given_a_published_course_exists
    @accrediting_provider = build(:accredited_provider, about_us: "about us", value_proposition: "value proposition")
    @course = create(
      :course,
      :with_full_time_sites,
      :secondary,
      :published,
      :open,
      provider: build(:provider),
      accrediting_provider: @accrediting_provider,
    )
  end
end
