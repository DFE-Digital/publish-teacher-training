# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Incomplete fields on organisation details" do
  scenario "the empty about fields prompt the user to fill them in" do
    given_i_am_authenticated_as_a_provider_user_with_nothing_written_about_the_organisation
    when_i_visit_the_organisation_details_page

    then_i_see_the_prompt("Enter why train with us", edit_publish_provider_recruitment_cycle_why_train_with_us_path(provider.provider_code, provider.recruitment_cycle_year))
    and_i_see_the_prompt("Enter training with disabilities", edit_publish_provider_recruitment_cycle_disability_support_path(provider.provider_code, provider.recruitment_cycle_year))
    and_no_field_says_it_is_empty
  end

  def given_i_am_authenticated_as_a_provider_user_with_nothing_written_about_the_organisation
    @user = create(
      :user,
      providers: [create(:provider, about_us: nil, value_proposition: nil, train_with_disability: nil)],
    )
    given_i_am_authenticated(user: @user)
  end

  def provider
    @user.providers.first
  end

  def when_i_visit_the_organisation_details_page
    visit details_publish_provider_recruitment_cycle_path(provider.provider_code, provider.recruitment_cycle_year)
  end

  def then_i_see_the_prompt(text, href)
    row = page.find(".govuk-summary-list__row", text:)

    expect(row).to have_css(".app-inset-text--important")
    expect(row).to have_link(text, href:)
    expect(row).to have_no_link("Change")
  end
  alias_method :and_i_see_the_prompt, :then_i_see_the_prompt

  def and_no_field_says_it_is_empty
    within(".govuk-summary-list", match: :first) do
      expect(page).to have_no_text("Not entered")
      expect(page).to have_no_text("Empty")
    end
  end
end
