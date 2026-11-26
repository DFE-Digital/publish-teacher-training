# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support course edit has no visa sponsorship question" do
  before do
    given_i_am_authenticated(user: create(:user, :admin))
  end

  scenario "fee-paying course" do
    when_i_edit(build(:course, funding: "fee"))
    then_there_is_no_visa_sponsorship_question
  end

  scenario "teacher degree apprenticeship course" do
    when_i_edit(build(:course, :with_teacher_degree_apprenticeship))
    then_there_is_no_visa_sponsorship_question
  end

  def when_i_edit(course)
    provider = create(:provider, courses: [course])
    visit edit_support_recruitment_cycle_provider_course_path(provider_id: provider.id, id: course.id, recruitment_cycle_year: provider.recruitment_cycle_year)
    expect(page).to have_button("Update")
  end

  def then_there_is_no_visa_sponsorship_question
    expect(page).to have_no_text("Visa sponsorship")
  end
end
