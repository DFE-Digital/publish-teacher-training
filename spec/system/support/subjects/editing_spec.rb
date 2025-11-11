# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Add match synonyms to subjects" do
  include DfESignInUserHelper

  before do
    given_a_support_user_exists
    and_a_subject_exists
    sign_in_system_test(user: @user)
  end

  scenario "adding synonyms to a subject" do
    given_i_visit_the_support_subjects_page
    then_i_see_the_list_of_subjects
    when_i_click_on_the_mathematics_subject
    then_i_see_the_subject_details_page
    and_i_see_no_synonyms_listed
    when_i_click_change_synonyms
    then_i_see_the_edit_synonyms_page
    when_i_enter_three_synonyms
    and_i_click_update_subject
    then_i_am_redirected_to_the_subject_page
    and_i_see_the_success_message
    and_i_see_all_three_synonyms_listed
  end

  scenario "adding synonyms with blank lines" do
    given_i_visit_the_support_subjects_page
    when_i_click_on_the_mathematics_subject
    when_i_click_change_synonyms
    when_i_enter_synonyms_with_blank_lines
    and_i_click_update_subject
    then_i_am_redirected_to_the_subject_page
    and_i_see_only_non_blank_synonyms
  end

  scenario "submitting empty synonyms form" do
    given_i_visit_the_support_subjects_page
    when_i_click_on_the_mathematics_subject
    when_i_click_change_synonyms
    when_i_submit_without_entering_synonyms
    then_i_am_redirected_to_the_subject_page
    and_i_see_no_synonyms_listed
  end

  def given_a_support_user_exists
    @user = create(:user, :admin)
  end

  def and_a_subject_exists
    @subject = create(:secondary_subject, :mathematics, match_synonyms: [])
  end

  def given_i_visit_the_support_subjects_page
    visit support_subjects_path
  end

  def then_i_see_the_list_of_subjects
    expect(page).to have_content("Subjects")
    expect(page).to have_content("Mathematics")
  end

  def when_i_click_on_the_mathematics_subject
    click_link_or_button "Mathematics"
  end

  def then_i_see_the_subject_details_page
    expect(page).to have_current_path(support_subject_path(@subject))
    expect(page).to have_content("Mathematics")
  end

  def and_i_see_no_synonyms_listed
    expect(page).to have_content("Match synonyms")
    expect(page).to have_content("None")
  end

  def when_i_click_change_synonyms
    within(".govuk-summary-list__row", text: "Match synonyms") do
      click_link_or_button "Change"
    end
  end

  def then_i_see_the_edit_synonyms_page
    expect(page).to have_current_path(edit_support_subject_path(@subject))
    expect(page).to have_content("Mathematics")
    expect(page).to have_field("Match synonyms")
    expect(page).to have_content("Enter one synonym per line")
  end

  def when_i_enter_three_synonyms
    fill_in "Match synonyms", with: "Maths\nMath\nNumeracy"
  end

  def and_i_click_update_subject
    click_link_or_button "Update subject"
  end

  def then_i_am_redirected_to_the_subject_page
    expect(page).to have_current_path(support_subject_path(@subject), ignore_query: true)
  end

  def and_i_see_the_success_message
    expect(page).to have_content("Subject updated")
  end

  def and_i_see_all_three_synonyms_listed
    within(".govuk-summary-list__row", text: "Match synonyms") do
      expect(page).to have_content("Maths")
      expect(page).to have_content("Math")
      expect(page).to have_content("Numeracy")
    end

    @subject.reload
    expect(@subject.match_synonyms).to contain_exactly("Maths", "Math", "Numeracy")
  end

  def when_i_enter_synonyms_with_blank_lines
    fill_in "Match synonyms", with: "Maths\n\n\nMath\n\nNumeracy\n"
  end

  def and_i_see_only_non_blank_synonyms
    within(".govuk-summary-list__row", text: "Match synonyms") do
      expect(page).to have_content("Maths")
      expect(page).to have_content("Math")
      expect(page).to have_content("Numeracy")
    end

    @subject.reload
    expect(@subject.match_synonyms).to contain_exactly("Maths", "Math", "Numeracy")
    expect(@subject.match_synonyms.length).to eq(3)
  end

  def when_i_submit_without_entering_synonyms
    click_link_or_button "Update subject"
  end
end
