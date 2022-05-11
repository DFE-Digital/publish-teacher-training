require "rails_helper"

RSpec.feature "PE allocations" do
  context "allocations state is open" do
    before do
      allow(Settings.features.allocations).to receive(:state).and_return("open")
      allow(Settings).to receive(:allocation_cycle_year).and_return(2022)
      given_i_am_authenticated(user: user_with_accredited_bodies)
      and_there_is_a_previous_recruitment_cycle
      and_there_is_a_previous_repeat_training_provider
    end

    context "when a provider does not have allocations assigned to them" do
      scenario "an accredited body views PE allocations page" do
        when_i_visit_allocations_page(accredited_body_with_no_allocations)
        then_it_has_the_correct_no_allocations_message
      end
    end

    context "When a provider has initial allocations assigned to them" do
      scenario "an accredited body views PE allocations page" do
        and_an_initial_allocation_exists_assigned_to_accredited_body
        when_i_visit_allocations_page(accredited_body_with_allocations)
        then_it_shows_the_initial_allocaions_table
      end
    end

    context "When a provider has repeat allocations assigned to them" do
      scenario "an accredited body views PE allocations page" do
        and_a_repeat_allocation_exists_assigned_to_accredited_body
        when_i_visit_allocations_page(accredited_body_with_allocations)
        then_it_shows_the_repeat_allocaions_table
      end
    end

    context "When a provider has initial and repeat allocations assigned to them" do
      scenario "an accredited body views PE allocations page" do
        and_an_initial_allocation_exists_assigned_to_accredited_body
        and_a_repeat_allocation_exists_assigned_to_accredited_body
        when_i_visit_allocations_page(accredited_body_with_allocations)
        then_it_shows_the_initial_and_repeat_allocaions_tables
      end
    end
  end

private

  def and_there_is_a_previous_recruitment_cycle
    previous_recruitment_cycle
  end

  def and_there_is_a_previous_repeat_training_provider
    previous_repeat_training_provider
  end

  def previous_recruitment_cycle
    @previous_recruitment_cycle ||= find_or_create(:recruitment_cycle, :previous)
  end

  def current_recruitment_cycle
    @current_recruitment_cycle ||= find_or_create(:recruitment_cycle)
  end

  def accredited_body_with_allocations
    @accredited_body ||= build(:provider, :accredited_body,
                               recruitment_cycle: current_recruitment_cycle)
  end

  def accredited_body_with_no_allocations
    @accredited_body_with_no_allocations ||= build(:provider, :accredited_body,
                                                   recruitment_cycle: current_recruitment_cycle)
  end

  def initial_training_provider
    @initial_training_provider ||= build(:provider, recruitment_cycle: current_recruitment_cycle)
  end

  def repeat_training_provider
    @repeat_training_provider ||= build(:provider, recruitment_cycle: current_recruitment_cycle)
  end

  def previous_repeat_training_provider
    @previous_repeat_training_provider ||= build(:provider, provider_code: repeat_training_provider.provider_code, recruitment_cycle: previous_recruitment_cycle)
  end

  def user_with_accredited_bodies
    @user_with_accredited_bodies ||= create(:user, providers:
      [accredited_body_with_allocations, accredited_body_with_no_allocations])
  end

  def next_allocation_cycle_period_text
    "#{Settings.allocation_cycle_year + 1} to #{Settings.allocation_cycle_year + 2}"
  end

  def and_an_initial_allocation_exists_assigned_to_accredited_body
    initial_allocation
  end

  def and_a_repeat_allocation_exists_assigned_to_accredited_body
    repeat_allocation
    previous_repeat_allocation
  end

  def when_i_visit_allocations_page(provider)
    allocations_page.load(provider_code: provider.provider_code,
                          recruitment_cycle_year: provider.recruitment_cycle_year)
  end

  def then_it_has_the_correct_no_allocations_message
    expect(allocations_page).to have_content(
      "You must request any fee-funded PE courses for #{next_allocation_cycle_period_text}",
    )
    expect(allocations_page).not_to have_initial_allocations
    expect(allocations_page).not_to have_repeat_allocations
  end

  def then_it_shows_the_initial_allocaions_table
    expect(allocations_page.initial_allocations.first.provider_name.text).to eq initial_training_provider.provider_name
    expect(allocations_page.initial_allocations.first.status.text).to eq "1 PLACE REQUESTED"
    expect(allocations_page).not_to have_repeat_allocations
  end

  def then_it_shows_the_repeat_allocaions_table
    expect(allocations_page).not_to have_initial_allocations
    expect(allocations_page.repeat_allocations.first.provider_name.text).to eq previous_repeat_training_provider.provider_name
    expect(allocations_page.repeat_allocations.first.status.text).to eq "REQUESTED"
  end

  def then_it_shows_the_initial_and_repeat_allocaions_tables
    expect(allocations_page.initial_allocations.first.provider_name.text).to eq initial_training_provider.provider_name
    expect(allocations_page.initial_allocations.first.status.text).to eq "1 PLACE REQUESTED"
    expect(allocations_page.repeat_allocations.first.provider_name.text).to eq previous_repeat_training_provider.provider_name
    expect(allocations_page.repeat_allocations.first.status.text).to eq "REQUESTED"
  end

  def initial_allocation
    @initial_allocation ||= create(
      :allocation,
      :initial,
      accredited_body: accredited_body_with_allocations,
      provider: initial_training_provider,
    )
  end

  def repeat_allocation
    @repeat_allocation ||= create(
      :allocation,
      :repeat,
      accredited_body: accredited_body_with_allocations,
      provider: repeat_training_provider,
    )
  end

  def previous_repeat_allocation
    @previous_repeat_allocation ||= create(
      :allocation,
      :repeat,
      accredited_body: accredited_body_with_allocations,
      provider: previous_repeat_training_provider,
    )
  end
end
