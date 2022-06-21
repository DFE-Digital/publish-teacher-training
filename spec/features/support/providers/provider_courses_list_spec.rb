# frozen_string_literal: true

require "rails_helper"

feature "View provider courses" do
  let(:user) { create(:user, :admin) }

  scenario "i can view courses belonging to a provider" do
    given_i_am_authenticated(user:)
    and_there_is_a_provider_with_courses
    when_i_visit_the_support_provider_show_page
    and_click_on_the_courses_tab
    then_i_should_see_a_table_of_courses
  end

  def course
    @course ||= create(:course)
  end

  def provider
    @provider ||= course.provider
  end

  def and_there_is_a_provider_with_courses
    provider
  end

  def when_i_visit_the_support_provider_show_page
    support_provider_show_page.load(id: provider.id)
  end

  def and_click_on_the_courses_tab
    support_provider_show_page.courses_tab.click
  end

  def then_i_should_see_a_table_of_courses
    expect(support_courses_index_page.courses_row.size).to eq(1)

    expect(support_courses_index_page.courses_row.first.name).to have_text(course.name)
    expect(support_courses_index_page.courses_row.first.name).to have_text(course.course_code)
    expect(support_courses_index_page.courses_row.first.change_link).to have_text("Change")
  end
end
