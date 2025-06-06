# create a test that checks the removal of an accredited provider from a partnership
# 1. set up users (provider user, accredited provider user, partnership)
# 2. create before block to ensurer provider user is athenticated
# 3. visit the accredited provider page for a training provider
# 4. click on the accredited provider which takes you to the details page
# 5. the details page should show the accredited provider details, without change links, and a remove button
# 6. click on remove button which takes you to the confirmation of removal page
# 7. click on 'remove accredited provider' button
# 8. redirected to accredited provider list with a success message
# 9. check that the accredited provider is no longer in the list of accredited providers for the provider
require "rails_helper"

RSpec.describe "Removing an accredited provider from a partnership", type: :system do
  let!(:provider) { create(:provider) }
  let!(:accredited_provider) { create(:provider, :accredited_provider) }
  let!(:partnership) { create(:provider_partnership, training_provider: provider, accredited_provider: accredited_provider) }
  let!(:user) { create(:user, providers: [provider]) }

  before { given_i_am_authenticated }

  context "as a training provider, when navigating to the accredited providers list" do
    before { when_i_visit_the_accredited_providers_page }

    scenario "I can view a list of accredited providers and the details page for an individual accredited provider" do
      then_i_see_the_accredited_provider_in_the_list
      when_i_click_the_accredited_provider_name
      then_i_see_the_accredited_provider_details_page
      then_i_do_not_see_change_links
      then_i_see_the_remove_button
      then_i_see_back_link_to_accredited_providers_page
      then_i_click_the_back_link_to_accredited_providers_page
      then_i_am_on_the_accredited_providers_page
    end

    scenario "I can successfully remove an accredited provider" do
      when_i_click_the_accredited_provider_name
      when_i_click_the_remove_link
      then_i_see_the_removal_confirmation_page

      when_i_confirm_removal
      then_i_see_the_success_message
      then_i_dont_see_the_accredited_provider_in_the_list
    end
  end

  # --- Step Definitions ---

  def given_i_am_authenticated
    sign_in_system_test(user: user)
  end

  def when_i_visit_the_accredited_providers_page
    visit publish_provider_recruitment_cycle_accredited_partnerships_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
    )
  end

  def then_i_see_the_accredited_provider_in_the_list
    expect(page).to have_link(accredited_provider.provider_name)
  end

  def when_i_click_the_accredited_provider_name
    click_link accredited_provider.provider_name
  end

  def then_i_see_the_accredited_provider_details_page
    expect(page).to have_content(accredited_provider.provider_name)
    expect(page).to have_content(accredited_provider.provider_code)
    expect(page).to have_current_path(
      details_publish_provider_recruitment_cycle_accredited_partnership_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        accredited_provider_code: accredited_provider.provider_code,
      ),
    )
  end

  def then_i_do_not_see_change_links
    expect(page).not_to have_link("Change")
  end

  def then_i_see_the_remove_button
    expect(page).to have_link("Remove accredited provider")
  end

  def then_i_see_back_link_to_accredited_providers_page
    expect(page).to have_link("All accredited providers", href: publish_provider_recruitment_cycle_accredited_partnerships_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
    ))
  end

  def then_i_click_the_back_link_to_accredited_providers_page
    click_link "All accredited providers"
  end

  def then_i_am_on_the_accredited_providers_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_accredited_partnerships_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
      ),
    )
  end

  def when_i_click_the_remove_link
    click_link "Remove accredited provider"
  end

  def then_i_see_the_removal_confirmation_page
    expect(page).to have_content("Are you sure you want to remove this accredited provider?")
    expect(page).to have_button("Remove accredited provider")
  end

  def when_i_confirm_removal
    click_button "Remove accredited provider"
  end

  def then_i_see_the_success_message
    expect(page).to have_content("Success\nAccredited provider removed")
  end

  def then_i_dont_see_the_accredited_provider_in_the_list
    expect(page).not_to have_link(accredited_provider.provider_name)
  end
end
