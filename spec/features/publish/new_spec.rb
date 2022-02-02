require "rails_helper"

feature "Creating a new course flow", type: :feature do
  before do
    given_i_am_authenticated_as_a_provider_user
    and_i_visit_the_new_course_level_page
  end

  context "with Primary level" do
    before do
      given_i_select_primary_level
      and_i_click_continue
    end

    scenario "with a single location" do
      
    end
  end

  context "with Secondary level" do
    before do
      given_i_select_secondary_level
      and_i_click_continue
    end

    scenario "with a single location" do
      
    end
  end

  context "with Further Education level" do
    before do
      given_i_select_further_education_level
      and_i_click_continue
    end

    scenario "with a single location" do
      
    end
  end

private

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def and_i_visit_the_new_course_level_page
    new_level_page.load(provider_code: @user.providers.last.provider_code, recruitment_cycle_year: Settings.current_recruitment_cycle_year)
  end

  def given_i_select_primary_level
    new_level_page.level_fields.primary.click
  end

  def given_i_select_secondary_level
    new_level_page.level_fields.secondary.click
  end

  def given_i_select_further_education_level
    new_level_page.level_fields.further_education.click
  end

  def and_i_click_continue
    new_level_page.continue.click
  end
end
