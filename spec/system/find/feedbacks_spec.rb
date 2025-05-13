require "rails_helper"

RSpec.describe "User feedback form", service: :find do
  context "when visiting the feedback form page" do
    before do
      when_i_visit_the_feedback_form
    end

    scenario "user submits valid feedback" do
      when_i_fill_in_valid_feedback
      click_button "Submit feedback"
      then_i_see_success_message_on_find_homepage
      and_the_feedback_is_saved_to_database
    end

    scenario "user submits form with missing fields" do
      click_button "Submit feedback"
      then_i_see_validation_errors_for_blank_fields
    end

    scenario "user submits feedback over the character limit" do
      when_i_enter_a_very_long_experience
      click_button "Submit feedback"
      then_i_see_validation_errors_for_character_limit
    end

    scenario "check for backlink presence and navigation on feedback form page" do
      then_i_see_backlink_to_find_homepage
      click_link_or_button "Back"
      then_i_am_on_the_find_homepage
    end
  end

  def when_i_visit_the_feedback_form
    visit(new_find_feedback_path)
  end

  def when_i_fill_in_valid_feedback
    choose "Very easy"
    fill_in "Tell us about your experience searching for teacher training courses", with: "Great experience!"
  end

  def when_i_enter_a_very_long_experience
    choose "Easy"
    fill_in "Tell us about your experience searching for teacher training courses", with: "x" * 1201
  end

  def then_i_see_success_message_on_find_homepage
    expect(page).to have_content("Feedback submitted")
    expect(page).to have_current_path(find_root_path)
  end

  def and_the_feedback_is_saved_to_database
    feedback = Feedback.last
    expect(feedback.ease_of_use).to eq("very_easy")
    expect(feedback.experience).to eq("Great experience!")
  end

  def then_i_see_validation_errors_for_blank_fields
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select how easy it is to find courses relevant to you")
    expect(page).to have_content("Enter your feedback")
  end

  def then_i_see_validation_errors_for_character_limit
    expect(page).to have_content("Feedback is too long (maximum is 1200 characters)")
  end

  def then_i_see_backlink_to_find_homepage
    expect(page).to have_link("Back", href: find_root_path)
  end

  def then_i_am_on_the_find_homepage
    expect(page).to have_current_path(find_root_path)
  end
end
