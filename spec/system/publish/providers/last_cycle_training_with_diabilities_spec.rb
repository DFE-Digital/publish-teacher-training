# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Editing a courses interview process with long form content", service: :publish do
  include DfESignInUserHelper

  let(:user) { create(:user) }

  before do
    FeatureFlag.activate(:long_form_content)
    sign_in_system_test(user:)
  end

  scenario "A user can see last years interview process and location" do
    given_there_is_a_provider
    and_this_provider_existed_last_cycle_with_disability_filled_in

    when_i_visit_the_organisation_page
    then_i_visit_the_disability_support_page
    expect(page).to have_content("Training with disabilities and other needs")
    expect(page).to have_content(@previous_cycle_provider.train_with_disability)
  end

  scenario "A user does NOT have a last years interview process and location" do
    given_there_is_a_provider
    when_i_visit_the_organisation_page
    then_i_visit_the_disability_support_page
    expect(page).not_to have_content("See what you wrote last cycle")
  end

  def when_i_visit_the_organisation_page
    visit "/publish/organisations/#{@provider.provider_code}/#{RecruitmentCycle.current.year}/details"
    expect(page).to have_content("Organisation details")
  end

  def then_i_visit_the_disability_support_page
    click_link "Change details about training with disabilities and other needs"
    expect(page).to have_current_path("/publish/organisations/#{@provider.provider_code}/#{RecruitmentCycle.current.year}/training-with-disabilities/edit")
    expect(page).to have_content("Training with disabilities and other needs")
  end

  def given_there_is_a_provider
    @current_cycle = RecruitmentCycle.current
    @provider = create(:provider, recruitment_cycle: @current_cycle)
    user.providers << @provider
    expect(user.providers.count).to eq(1)
  end

  def and_this_provider_existed_last_cycle_with_disability_filled_in
    @previous_cycle = create(:recruitment_cycle, :previous)
    @previous_cycle_provider = create(:provider, recruitment_cycle: @previous_cycle, provider_code: @provider.provider_code, train_with_disability: generate_text(50))
    user.providers << @previous_cycle_provider
    expect(user.providers.count).to eq(2)
  end

  def generate_text(word_count)
    "#{Faker::Lorem.words(number: word_count).join(' ').capitalize}."
  end
end
