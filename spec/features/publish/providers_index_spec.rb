require "rails_helper"

feature "Providers index" do
  context "user with multiple accredited bodies" do
    let(:current_recruitment_cycle) { find_or_create(:recruitment_cycle) }
    let(:accredited_body) { create(:provider, :accredited_body, recruitment_cycle: current_recruitment_cycle) }
    let(:accredited_body1) { create(:provider, :accredited_body, recruitment_cycle: current_recruitment_cycle) }
    let(:user) { create(:user, providers: [accredited_body, accredited_body1]) }

    scenario "view page as Mary" do
      given_i_am_authenticated(user: user)
      when_i_visit_the_publish_providers_index_page
      i_should_see_the_provider_list
      i_should_not_see_the_admin_search_box
    end
  end

  context "admin user" do
    let(:user) { create(:user, :admin) }

    scenario "view page as Colin" do
      given_i_am_authenticated(user: user)
      and_there_are_providers
      when_i_visit_the_publish_providers_index_page
      i_should_see_the_provider_list
      i_should_see_the_admin_search_box
      i_should_see_the_pagination_link
      i_can_search_with_provider_details
    end
  end

  def i_can_search_with_provider_details
    publish_providers_index_page.search_input.set "Really big school (A01)"
    publish_providers_index_page.search_button.click
    expect(publish_providers_show_page).to be_displayed
    expect(publish_providers_show_page.current_url).to end_with("A01")
  end

  def i_should_see_the_pagination_link
    expect(publish_providers_index_page.pagination_pages.text).to eq("2 of 3")
  end

  def when_i_visit_the_publish_providers_index_page
    publish_providers_index_page.load
  end

  def i_should_see_the_provider_list
    expect(publish_providers_index_page).to have_provider_list
  end

  def i_should_see_the_admin_search_box
    expect(publish_providers_index_page).to have_admin_search_box
  end

  def i_should_not_see_the_admin_search_box
    expect(publish_providers_index_page).not_to have_admin_search_box
  end

  def and_there_are_providers
    create(:provider, provider_name: "Really big school", provider_code: "A01", courses: [build(:course, course_code: "2VVZ")])
    create(:provider, provider_name: "Slightly smaller school", provider_code: "A02", courses: [build(:course, course_code: "2VVZ")])
    create_list(:provider, 20)
  end
end
