# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Delete school under provider as an admin" do
  describe "Deleting a school" do
    scenario do
      given_i_am_authenticated_as_an_admin_user
      and_there_is_a_provider_site
      and_the_provider_has_a_second_school
      and_i_visit_the_support_provider_school_show_page
      when_i_click_remove_school_link
      then_i_am_on_the_school_delete_page
      when_i_click_cancel
      then_i_am_on_the_school_show_page

      when_i_click_remove_school_link
      and_i_click_remove_school_button
      then_i_am_on_the_index_page
      and_the_school_is_deleted
    end

    scenario "when the school becomes associated with a course before removal" do
      given_i_am_authenticated_as_an_admin_user
      and_there_is_a_provider_site
      and_the_provider_has_a_second_school
      and_i_visit_the_support_provider_school_show_page
      when_i_click_remove_school_link
      then_i_am_on_the_school_delete_page

      given_there_is_an_associated_course
      and_i_click_remove_school_button
      then_i_see_the_school_could_not_be_removed
      and_the_school_is_not_deleted
    end

    scenario "when it is the provider's only school" do
      given_i_am_authenticated_as_an_admin_user
      and_there_is_a_provider_site
      and_i_visit_the_support_provider_school_show_page
      when_i_click_remove_school_link
      then_i_am_on_the_school_delete_page
      and_i_am_told_it_is_the_only_school
    end

    scenario "after the schools remodel cycle without a legacy site" do
      given_i_am_authenticated_as_an_admin_user
      and_there_is_a_provider_school_after_the_schools_remodel_cycle_without_a_legacy_site
      and_the_future_provider_has_a_second_school
      when_i_visit_the_support_provider_schools_index_page_after_the_schools_remodel_cycle
      then_i_see_the_provider_school_listed_with_its_uuid

      when_i_click_the_provider_school
      then_i_see_the_provider_school_details

      when_i_remove_the_provider_school
      then_i_am_on_the_index_page
      and_the_provider_school_is_deleted
    end
  end

  def and_there_is_a_provider_school_after_the_schools_remodel_cycle_without_a_legacy_site
    expect(Site.find_by_uuid(future_provider_school.uuid)).to be_nil
  end

  def and_the_provider_has_a_second_school
    create(:provider_school, provider: @provider, gias_school: create(:gias_school, name: "Second School"), site_code: "Z")
  end

  def and_the_future_provider_has_a_second_school
    create(:provider_school, provider: future_provider, gias_school: create(:gias_school, name: "Second Future School"), site_code: "Z")
  end

  def and_i_am_told_it_is_the_only_school
    expect(page).to have_content("#{@provider_school.location_name} is the only school for School of Cats.")
    expect(page).to have_content("To remove it, you must first add another school.")
    expect(support_provider_school_delete_page).not_to have_remove_school_button
  end

  def when_i_visit_the_support_provider_schools_index_page_after_the_schools_remodel_cycle
    support_provider_schools_index_page.load(
      recruitment_cycle_year: future_recruitment_cycle.year,
      provider_id: future_provider.id,
    )
  end

  def then_i_see_the_provider_school_listed_with_its_uuid
    expect(support_provider_schools_index_page.schools.first.name).to have_text(future_gias_school.name)
    expect(support_provider_schools_index_page.schools.first.code).to have_text("- (dash)")
    expect(support_provider_schools_index_page.schools.first.urn).to have_text(future_gias_school.urn)
    expect(support_provider_schools_index_page.schools.first.edit_link[:href]).to include(future_provider_school.uuid)
  end

  def when_i_click_the_provider_school
    support_provider_schools_index_page.schools.first.edit_link.click
  end

  def then_i_see_the_provider_school_details
    expect(support_provider_school_show_page).to be_displayed
    expect(page).to have_content("Future School (Main Site)")
    expect(page).to have_content("School code-", normalize_ws: true)
    expect(page).to have_content("URN654321", normalize_ws: true)
    expect(page).to have_content("Address 1 Future Road Future Building Future Quarter Future Town Future County FT1 1AA", normalize_ws: true)
  end

  def when_i_remove_the_provider_school
    support_provider_school_show_page.remove_school_link.click
    support_provider_school_delete_page.remove_school_button.click
  end

  def and_the_provider_school_is_deleted
    expect(Provider::School.where(id: future_provider_school.id)).to be_empty
  end

  def future_recruitment_cycle
    @future_recruitment_cycle ||= create(:recruitment_cycle, year: Settings.schools_remodel_cycle_year + 1)
  end

  def future_provider
    @future_provider ||= create(:provider, provider_name: "Future Provider", recruitment_cycle: future_recruitment_cycle)
  end

  def future_provider_school
    @future_provider_school ||= create(:provider_school, provider: future_provider, gias_school: future_gias_school, site_code: "-")
  end

  def future_gias_school
    @future_gias_school ||= create(
      :gias_school,
      name: "Future School",
      urn: "654321",
      address1: "1 Future Road",
      address2: "Future Building",
      address3: "Future Quarter",
      town: "Future Town",
      county: "Future County",
      postcode: "FT1 1AA",
    )
  end

  def and_the_school_is_deleted
    expect(@provider.sites.count).to eq 0
    expect(Provider::School.where(id: @provider_school.id)).to be_empty
  end

  def and_the_school_is_not_deleted
    expect(@provider.sites.count).to eq 1
    expect(Provider::School.where(id: @provider_school.id)).to contain_exactly(@provider_school)
  end

  def then_i_am_on_the_index_page
    expect(support_provider_schools_index_page).to be_displayed
    expect(page).to have_text "School successfully deleted"
  end

  def and_i_click_remove_school_button
    click_link_or_button "Remove school"
  end

  def then_i_am_on_the_school_show_page
    expect(support_provider_school_show_page).to be_displayed
  end

  def when_i_click_cancel
    click_link_or_button "Cancel"
  end

  def then_i_am_on_the_school_delete_page
    expect(support_provider_school_delete_page).to be_displayed
  end

  def when_i_click_remove_school_link
    click_link_or_button "Remove school"
  end

  def and_i_visit_the_support_provider_school_show_page
    support_provider_school_show_page.load(recruitment_cycle_year: @provider.recruitment_cycle.year, provider_id: @provider.id, id: @provider_school.uuid)
  end

  def and_there_is_a_provider_site
    gias_school = create(:gias_school)
    @provider = create(:provider, provider_name: "School of Cats")
    @site = create(:site, provider: @provider, **gias_school.school_attributes)
    @provider_school = create(:provider_school, provider: @provider, gias_school:, site_code: @site.code, uuid: @site.uuid)
  end

  def given_there_is_an_associated_course
    create(
      :course_school,
      course: create(:course, provider: @provider),
      provider_school: @provider_school,
      gias_school: @provider_school.gias_school,
      site_code: @provider_school.site_code,
    )
  end

  def given_i_am_authenticated_as_an_admin_user
    given_i_am_authenticated(user: create(:user, :admin))
  end

  def then_i_see_the_school_could_not_be_removed
    expect(support_provider_school_delete_page).to be_displayed
    expect(page).to have_content("This school could not be removed because it is used by a course")
  end
end
