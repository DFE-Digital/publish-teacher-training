# frozen_string_literal: true

require "rails_helper"

RSpec.describe "View providers" do
  let(:user) { create(:user, :admin) }

  before do
    given_i_am_authenticated(user:)
    and_there_are_providers
    when_i_visit_the_support_provider_index_page
  end

  scenario "i can view the providers" do
    then_i_see_the_providers
  end

  def and_there_are_providers
    create_list(:provider, 2)
  end

  def when_i_visit_the_support_provider_index_page
    support_provider_index_page.load(recruitment_cycle_year: Find::CycleTimetable.cycle_year_from_time(Time.zone.now))
  end

  def then_i_see_the_providers
    expect(support_provider_index_page.providers.size).to eq(2)
  end
end
