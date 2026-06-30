# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Editing a courses interview process with long form content", service: :publish do
  include DfESignInUserHelper

  let(:user) { create(:user) }

  before do
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

  scenario "A user editing a next cycle provider sees content from that provider's previous cycle" do
    given_there_is_a_provider_in_the_next_cycle
    and_the_same_provider_existed_this_cycle_with_disability_filled_in

    when_i_visit_the_next_cycle_disability_support_page
    expect(page).to have_content("Training with disabilities and other needs")
    expect(page).to have_content("See what you wrote last cycle")
    expect(page).to have_content(@current_cycle_provider.train_with_disability)
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

  def given_there_is_a_provider_in_the_next_cycle
    @next_cycle = create(:recruitment_cycle, :next)
    @next_cycle_provider = create(:provider, recruitment_cycle: @next_cycle)
    user.providers << @next_cycle_provider
  end

  def and_the_same_provider_existed_this_cycle_with_disability_filled_in
    @current_cycle_provider = create(
      :provider,
      recruitment_cycle: RecruitmentCycle.current,
      provider_code: @next_cycle_provider.provider_code,
      train_with_disability: generate_text(50),
    )
    user.providers << @current_cycle_provider
  end

  def when_i_visit_the_next_cycle_disability_support_page
    visit "/publish/organisations/#{@next_cycle_provider.provider_code}/#{@next_cycle.year}/training-with-disabilities/edit"
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
