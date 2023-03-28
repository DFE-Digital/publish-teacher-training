# frozen_string_literal: true

require 'rails_helper'

feature "Managing a provider's schools", { can_edit_current_and_next_cycles: false } do
  scenario "i can view and update a provider's schools" do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_schools_page
    then_i_should_see_a_list_of_schools

    when_i_click_add_a_school
    then_i_can_add_a_school
    when_i_click_on_a_school
    then_i_can_update_its_details
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(
      user: create(:user, providers: [create(:provider, sites: [build(:site)])])
    )
  end

  def when_i_visit_the_schools_page
    publish_schools_index_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year
    )
  end

  def then_i_should_see_a_list_of_schools
    expect(publish_schools_index_page.schools.size).to eq(1)

    expect(publish_schools_index_page.schools.first.name).to have_text(site.location_name)
    expect(publish_schools_index_page.schools.first.code).to have_text(site.code)
    expect(publish_schools_index_page.schools.first.urn).to have_text(site.urn)
  end

  def when_i_click_add_a_school
    publish_schools_index_page.add_school.click
  end

  def then_i_can_add_a_school
    expect(page).to have_current_path publish_school_new_page.url(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year
    )

    publish_school_new_page.name_field.set 'Some place'
    publish_school_new_page.address1_field.set '123 Test Street'
    publish_school_new_page.address3_field.set 'London'
    publish_school_new_page.postcode_field.set 'KT8 9AU'
    publish_school_new_page.submit.click

    expect(publish_schools_index_page.schools.size).to eq(2)
    expect(publish_schools_index_page.schools.last.name).to have_text('Some place')
  end

  def when_i_click_on_a_school
    publish_schools_index_page.schools.last.edit_link.click
  end

  def then_i_can_update_its_details
    expect(page).to have_current_path publish_school_edit_page.url(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      school_id: Site.last.id
    )

    publish_school_edit_page.name_field.set 'Renamed place'
    publish_school_new_page.submit.click
    expect(publish_schools_index_page.schools.size).to eq(2)
    expect(publish_schools_index_page.schools.last.name).to have_text('Renamed place')
  end

  private

  def provider
    @current_user.providers.first
  end

  def site
    @site ||= provider.sites.first
  end
end
