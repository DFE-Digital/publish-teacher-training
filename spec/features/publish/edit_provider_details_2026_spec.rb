# frozen_string_literal: true

require "rails_helper"

feature "Why Train With Us section in 2026 cycle +" do
  scenario "Provider user edits provider details" do
    given_i_am_a_provider_user_as_a_provider_user
    when_i_visit_the_details_page
    then_i_can_edit_info_about_training_with_us
    then_i_can_edit_info_about_disabilities_and_other_needs
    then_i_can_edit_school_placements
  end

  def given_i_am_a_provider_user_as_a_provider_user
    @recruitment_cycle = create(:recruitment_cycle, :next)
    @provider = create(:provider, recruitment_cycle: @recruitment_cycle)
    course = create(:course, :with_accrediting_provider, provider: @provider)

    @provider.accredited_partnerships.create(accredited_provider: course.accrediting_provider)

    given_i_am_authenticated(user: create(:user, providers: [@provider]))
    @accrediting_provider = @provider.accredited_partners.first
  end

  def when_i_visit_the_details_page
    publish_provider_details_show_page.load(
      provider_code: @provider.provider_code,
      recruitment_cycle_year: @provider.recruitment_cycle_year,
    )
  end

  def then_i_can_edit_info_about_training_with_us
    visit("/publish/organisations/#{@provider.provider_code}/#{@recruitment_cycle.year}/details")
    page.click_link "Change details about training with your organisation"

    expect(page).to have_current_path edit_publish_provider_recruitment_cycle_why_train_with_us_path(
      provider_code: @provider.provider_code,
      recruitment_cycle_year: @provider.recruitment_cycle_year,
    )

    page.find("#publish-why-train-with-us-form-about-us-field").set ""

    page.click_button "Update why train with us"
    within publish_provider_details_edit_page.error_summary do
      expect(page).to have_content "Enter what kind of organisation you are"
    end

    page.find("#publish-why-train-with-us-form-about-us-field-error").set "Updated: Training with you"
    page.click_button "Update why train with us"

    expect(page).to have_content "Your changes have been published"
    within_summary_row "Why train with us" do
      expect(page).to have_content "Updated: Training with you"
    end
  end

  def then_i_can_edit_info_about_disabilities_and_other_needs
    visit(details_publish_provider_recruitment_cycle_path(provider_code: @provider.provider_code, year: @provider.recruitment_cycle_year))
    click_link "Change details about training with disabilities and other needs"

    page.find("#publish-disability-support-form-train-with-disability-field").set("Updated: training with disabilities")
    click_button "Update training with disabilities"

    expect(page).to have_content "Your changes have been published"
    within_summary_row "Training with disabilities and other needs" do
      expect(page).to have_content "Updated: training with disabilities"
    end
  end

  def then_i_can_edit_school_placements
    within(publish_provider_details_show_page.selectable_school) do
      expect(page).to have_content("Yes")
    end
    publish_provider_details_show_page.selectable_school_change_link.click
    expect(page.find_by_id("provider-selectable-school-true-field")).to be_checked
    page.find("input#provider-selectable-school-field").click
    page.click_on("Update school placement preferences")

    publish_provider_details_show_page.selectable_school.click
    within(publish_provider_details_show_page.selectable_school) do
      expect(page).to have_content("No")
    end
  end
end
