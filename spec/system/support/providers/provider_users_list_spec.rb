# frozen_string_literal: true

require "rails_helper"

RSpec.describe "View provider users" do
  let(:user) { create(:user, :admin) }

  scenario "i can view users belong to a provider" do
    given_i_am_authenticated(user:)
    and_there_is_a_provider
    when_i_visit_the_support_provider_show_page
    and_click_on_the_users_tab
    then_i_should_see_a_table_of_users
  end

  def and_there_is_a_provider
    @provider = create(:provider, :with_users)
  end

  def when_i_visit_the_support_provider_show_page
    support_provider_show_page.load(recruitment_cycle_year: Find::CycleTimetable.cycle_year_for_time(Time.zone.now), id: @provider.id)
  end

  def and_click_on_the_users_tab
    support_provider_show_page.users_tab.click
  end

  def then_i_should_see_a_table_of_users
    expect(support_provider_users_index_page.users.size).to eq(4)
  end
end
