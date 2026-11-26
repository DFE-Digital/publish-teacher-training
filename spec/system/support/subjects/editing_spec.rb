# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Add match synonyms to subjects" do
  include DfESignInUserHelper
  include SettingsPageSpecsHelper

  before do
    given_a_support_user_exists
    sign_in_system_test(user: @user)
  end

  scenario "I can navigate back to the settings page via the backlink", travel: mid_cycle do
    given_i_visit_the_support_subjects_page
    then_i_see_the_backlink_to_the_settings_page
    then_i_click_back_button
    then_i_am_on_the_settings_page
  end

  scenario "searching for subjects and adding synonyms" do
    given_i_visit_the_support_subjects_page
    when_i_search_for_mathematics
    then_i_see_only_mathematics_in_results
    and_the_subject_filter_is_active
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
    when_i_go_back_to_subjects_index
  end

  scenario "searching for a subject using autocomplete", :js do
    given_i_visit_the_support_subjects_page
    when_i_type_part_of_a_subject
    then_i_see_matching_subject_suggestions
    when_i_select_mathematics_from_the_suggestions
    then_mathematics_is_in_the_search_field
  end

  scenario "clearing a subject filter" do
    given_i_visit_the_support_subjects_page
    when_i_search_for_mathematics
    and_i_clear_the_filters
    then_the_subject_filter_is_cleared
  end

  scenario "adding synonyms with blank lines" do
    given_i_visit_the_support_subjects_page
    when_i_search_for_mathematics
    when_i_click_on_the_mathematics_subject
    when_i_click_change_synonyms
    when_i_enter_synonyms_with_blank_lines
    and_i_click_update_subject
    then_i_am_redirected_to_the_subject_page
    and_i_see_only_non_blank_synonyms
  end

  scenario "submitting empty synonyms form" do
    given_i_visit_the_support_subjects_page
    when_i_search_for_mathematics
    when_i_click_on_the_mathematics_subject
    when_i_click_change_synonyms
    when_i_enter_three_synonyms
    and_i_click_update_subject
    then_i_am_redirected_to_the_subject_page
    when_i_click_change_synonyms
    when_i_enter_empty_synonyms
    and_i_click_update_subject
    then_i_am_redirected_to_the_subject_page
    and_i_see_no_synonyms_listed
  end

  def given_a_support_user_exists
    @user = create(:user, :admin)
  end

  def given_mathematics_has_synonyms
    mathematics.update!(match_synonyms: %w[Maths Math Numeracy])
  end

  def given_i_visit_the_support_subjects_page
    visit support_subjects_path
  end

  def when_i_search_for_mathematics
    fill_in "text_search", with: "Mathematics"
    click_link_or_button "Apply filters"
  end

  def then_i_see_only_mathematics_in_results
    expect(page).to have_content("Mathematics")
    expect(page).to have_content("Primary with mathematics")

    within("table tbody") do
      expect(page).to have_css("tr", count: 2)
    end
  end

  def and_the_subject_filter_is_active
    expect(page).to have_field("text_search", with: "Mathematics")
    expect(page).to have_link("Clear")
    within(".moj-filter-tags") do
      expect(page).to have_link("Mathematics")
    end
  end

  def when_i_click_on_the_mathematics_subject
    click_link_or_button "Mathematics"
  end

  def then_i_see_the_subject_details_page
    expect(page).to have_current_path(support_subject_path(mathematics))
    expect(page).to have_content("Mathematics")
  end

  def and_i_see_no_synonyms_listed
    within(".govuk-summary-list") do
      expect(page).to have_content("Synonyms")
      expect(page).to have_content("[]")
    end
  end

  def when_i_click_change_synonyms
    within(".govuk-summary-list__row", text: "Synonyms") do
      click_link_or_button "Change"
    end
  end

  def then_i_see_the_edit_synonyms_page
    expect(page).to have_current_path(edit_support_subject_path(mathematics))
    expect(page).to have_content("Mathematics")
    expect(page).to have_field("subject[match_synonyms_text]")
    expect(page).to have_content("Enter one synonym per line")
  end

  def when_i_enter_three_synonyms
    fill_in "subject[match_synonyms_text]", with: "Maths\nMath\nNumeracy"
  end

  def and_i_click_update_subject
    click_link_or_button(
      I18n.t("support.subjects.update_subject_synonyms", subject_name: mathematics.subject_name),
    )
  end

  def then_i_am_redirected_to_the_subject_page
    expect(page).to have_current_path(support_subject_path(mathematics), ignore_query: true)
  end

  def and_i_see_the_success_message
    expect(page).to have_content(
      I18n.t("support.subjects.synonyms_updated"),
    )
  end

  def and_i_see_all_three_synonyms_listed
    within(".govuk-summary-list") do
      synonym_row = page.find(".govuk-summary-list__row", text: "Synonyms")
      within(synonym_row) do
        expect(page).to have_content("Maths")
        expect(page).to have_content("Math")
        expect(page).to have_content("Numeracy")
      end
    end

    mathematics.reload
    expect(mathematics.match_synonyms).to contain_exactly("Maths", "Math", "Numeracy")
  end

  def when_i_go_back_to_subjects_index
    visit support_subjects_path
  end

  def when_i_type_part_of_a_subject
    fill_in "text_search", with: "Mat"
  end

  def then_i_see_matching_subject_suggestions
    within("[role='listbox']") do
      expect(page).to have_css(
        "[role='option']",
        text: "Mathematics",
        exact_text: true,
      )

      expect(page).to have_css(
        "[role='option']",
        text: "Primary with mathematics",
        exact_text: true,
      )
    end
  end

  def when_i_select_mathematics_from_the_suggestions
    page.find(
      "[role='option']",
      text: "Mathematics",
      exact_text: true,
    ).click
  end

  def then_mathematics_is_in_the_search_field
    expect(page).to have_field(
      "text_search",
      with: "Mathematics",
    )
  end

  def and_i_clear_the_filters
    click_link_or_button "Clear"
  end

  def then_the_subject_filter_is_cleared
    expect(page).to have_current_path(support_subjects_path)
    expect(page).to have_field("text_search")
    expect(page).to have_no_css(".moj-filter-tags")
    expect(page).to have_no_link("Clear")
  end

  def when_i_enter_synonyms_with_blank_lines
    fill_in "subject[match_synonyms_text]", with: "Maths\n\n\nMath\n\nNumeracy\n"
  end

  def when_i_enter_empty_synonyms
    fill_in "subject[match_synonyms_text]", with: ""
  end

  def and_i_see_only_non_blank_synonyms
    within(".govuk-summary-list") do
      synonym_row = page.find(".govuk-summary-list__row", text: "Synonyms")
      within(synonym_row) do
        expect(page).to have_content("Maths")
        expect(page).to have_content("Math")
        expect(page).to have_content("Numeracy")
      end
    end

    mathematics.reload
    expect(mathematics.match_synonyms).to contain_exactly("Maths", "Math", "Numeracy")
    expect(mathematics.match_synonyms.length).to eq(3)
  end

  def mathematics
    @mathematics ||= Subject.find_by(subject_name: "Mathematics")
  end
end
