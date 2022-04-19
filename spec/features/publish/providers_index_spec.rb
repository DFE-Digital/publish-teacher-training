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
    end
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
  end
end
