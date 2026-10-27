# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Deleting a provider from user" do
  context "when the support user is an admin" do
    before do
      given_i_am_authenticated(user: create(:user, :admin))
      and_a_user_provider_relationship_exists_to_remove
      when_i_visit_the_user_show_providers_page
    end

    scenario "Deleting a user-provider relationship" do
      when_i_click_the_remove_user_from_provider_button
      then_i_am_asked_to_confirm
      when_i_confirm_removal
      then_i_am_taken_to_the_user_show_providers_page
      with_a_success_message
      and_the_user_provider_relationship_is_destroyed
    end
  end

  scenario "a support user who is not an admin cannot remove a provider" do
    and_a_user_provider_relationship_exists_to_remove
    given_i_am_authenticated(user: create(:user))
    when_i_visit_the_remove_provider_page
    then_i_am_not_permitted
    and_the_user_permission_remains
  end

private

  def and_a_user_provider_relationship_exists_to_remove
    @provider = create(:provider)
    @user = create(:user, providers: [@provider])
    @user_permission = @user.user_permissions.find_by!(provider: @provider)
  end

  def when_i_visit_the_user_show_providers_page
    support_user_show_providers_page.load(recruitment_cycle_year: Find::CycleTimetable.current_year, id: @user.id)
  end

  def when_i_click_the_remove_user_from_provider_button
    support_user_show_providers_page.remove_user_from_provider_button.click
  end

  def then_i_am_asked_to_confirm
    expect(page).to have_content("Are you sure you want to remove #{@user.full_name} from #{@provider.provider_name}?")
    expect(page).to have_content("#{@user.full_name} will be sent an email to tell them you removed them from #{@provider.provider_name}")
  end

  def when_i_confirm_removal
    click_button "Remove user"
  end

  def then_i_am_taken_to_the_user_show_providers_page
    expect(support_user_show_providers_page).to be_displayed
  end

  def with_a_success_message
    expect(page).to have_content("#{@user.full_name} has been removed from #{@provider.provider_name}")
  end

  def and_the_user_provider_relationship_is_destroyed
    @user.reload
    expect(UserPermission.exists?(@user_permission.id)).to be false
    expect(@user.providers).to be_empty
    expect(support_user_show_providers_page.provider_rows).to be_empty
  end

  def and_the_user_permission_remains
    expect(UserPermission.exists?(@user_permission.id)).to be true
    expect(@user.reload.providers).to include(@provider)
  end

  def when_i_visit_the_remove_provider_page
    visit remove_provider_support_recruitment_cycle_user_path(
      Find::CycleTimetable.current_year,
      @user,
      provider_id: @provider.id,
    )
  end

  def then_i_am_not_permitted
    expect(page).to have_content("You are not permitted to see this page")
  end

  def and_i_click_on_the_providers_tab
    support_user_show_providers_page.providers_tab.click
  end
end
