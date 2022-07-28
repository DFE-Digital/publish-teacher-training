# frozen_string_literal: true

require "rails_helper"

feature "Creating a new user" do
  let(:user) { create(:user, :admin) }

  before do
    given_i_am_authenticated(user:)
    when_i_visit_the_user_index_page
    and_i_click_on_add_a_user
    then_i_am_taken_to_the_support_user_new_page
  end

  describe "Adding a user" do
    context "Valid details" do
      scenario "Adding a new user record" do
        and_i_fill_in_first_name
        and_i_fill_in_last_name
        and_i_fill_in_email
        when_i_save_the_form
        then_i_am_taken_to_the_user_index_page
      end
    end

    context "Invalid details" do
      scenario "Failing to add a user trigging the validations" do
        when_i_save_the_form
        then_i_should_see_the_error_summary
      end
    end
  end

  def when_i_visit_the_user_index_page
    support_users_index_page.load(recruitment_cycle_year: Settings.current_recruitment_cycle_year)
  end

  def and_i_click_on_add_a_user
    support_users_index_page.add_a_user.click
  end

  def then_i_am_taken_to_the_support_user_new_page
    support_user_new_page.load(recruitment_cycle_year: Settings.current_recruitment_cycle_year)
  end

  def and_i_fill_in_first_name
    support_user_new_page.first_name.set("Luke")
  end

  def and_i_fill_in_last_name
    support_user_new_page.last_name.set("Skywalker")
  end

  def and_i_fill_in_email
    support_user_new_page.email.set("lukeskywalker@jedi.com")
  end

  def when_i_save_the_form
    support_user_new_page.submit.click
  end

  def then_i_am_taken_to_the_user_index_page
    support_users_index_page.load(recruitment_cycle_year: Settings.current_recruitment_cycle_year)
  end

  def then_i_should_see_the_error_summary
    expect(support_user_new_page.error_summary).to be_visible
  end
end
