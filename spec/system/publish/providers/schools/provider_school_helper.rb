# frozen_string_literal: true

module ProviderSchoolHelper
  def given_i_am_authenticated_as_a_provider_user
    gias_school = create(:gias_school)
    provider = create(:provider, sites: [build(:site, **gias_school.school_attributes)])
    site = provider.sites.first
    create(:provider_school, provider:, gias_school:, site_code: site.code, uuid: site.uuid)

    given_i_am_authenticated(user: create(:user, providers: [provider]))
  end

  def when_i_visit_the_schools_page
    publish_schools_index_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year,
    )
  end

  def then_i_see_a_list_of_schools
    expect(publish_schools_index_page.schools.size).to eq(1)

    provider_school = provider.schools.first
    expect(publish_schools_index_page.schools.first.name).to have_text(provider_school.location_name)
    expect(publish_schools_index_page.schools.first.code).to have_text(provider_school.code)
    expect(publish_schools_index_page.schools.first.urn).to have_text(provider_school.urn)
  end

  def then_i_am_on_the_index_page
    expect(publish_schools_index_page).to be_displayed
  end

  def then_i_see_an_error_message
    expect(page).to have_text("Enter a name")
  end

  def provider
    @current_user.providers.first
  end

  def site
    @site ||= provider.sites.first
  end

  def then_i_am_on_the_school_show_page
    expect(publish_school_show_page).to be_displayed
  end
end
