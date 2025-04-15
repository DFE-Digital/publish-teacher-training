# frozen_string_literal: true

require "rails_helper"

feature "About Your Organisation section", { can_edit_current_and_next_cycles: false } do
  scenario "Provider user edits provider details" do
    given_i_am_a_provider_user_as_a_provider_user
    when_i_visit_the_details_page
    then_i_can_edit_info_about_training_with_us
    then_i_can_edit_info_about_disabilities_and_other_needs
    then_i_can_edit_school_placements
  end

  def given_i_am_a_provider_user_as_a_provider_user
    @provider = create(:provider)
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
    publish_provider_details_show_page.train_with_us_link.click
    expect(page).to have_current_path publish_provider_details_edit_page.url(
      provider_code: @provider.provider_code,
      recruitment_cycle_year: @provider.recruitment_cycle_year,
    )

    publish_provider_details_edit_page.training_with_you_field.set ""
    publish_provider_details_edit_page.save_and_publish.click
    within publish_provider_details_edit_page.error_summary do
      expect(page).to have_content "Enter details about training with you"
    end

    publish_provider_details_edit_page.training_with_you_field.set "Updated: Training with you"
    publish_provider_details_edit_page.save_and_publish.click

    expect(page).to have_content "Your changes have been published"
    within_summary_row "Training with your organisation" do
      expect(page).to have_content "Updated: Training with you"
    end
  end

  def then_i_can_edit_info_about_disabilities_and_other_needs
    publish_provider_details_show_page.train_with_disability_link.click

    publish_provider_details_edit_page.train_with_disability_field.set "Updated: training with disabilities"
    publish_provider_details_edit_page.save_and_publish.click

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
