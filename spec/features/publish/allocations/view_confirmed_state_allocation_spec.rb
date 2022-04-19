require "rails_helper"

RSpec.feature "PE allocations" do
  context "allocations state is confirmed" do
    before do
      allow(Settings.features.allocations).to receive(:state).and_return("confirmed")
      allow(Settings).to receive(:allocation_cycle_year).and_return(2022)
      given_i_am_authenticated(user: user_with_accredited_bodies)
      and_there_is_a_previous_recruitment_cycle
    end

    context "when a provider does not have allocations assigned to them" do
      scenario "an accredited body views PE allocations page" do
        when_i_visit_allocations_page(accredited_body_with_no_allocation)
        then_it_has_the_correct_no_allocations_message
      end
    end

    context "When a provider has allocations assigned to them" do
      scenario "an accredited body views PE allocations page" do
        and_an_allocation_exists_assigned_to_accredited_body
        when_i_visit_allocations_page(accredited_body_with_allocation)
        then_it_has_the_correct_allocations_content
      end
    end
  end

private

  def and_there_is_a_previous_recruitment_cycle
    find_or_create(:recruitment_cycle, :previous)
  end

  def current_recruitment_cycle
    @current_recruitment_cycle ||= find_or_create(:recruitment_cycle)
  end

  def accredited_body_with_allocation
    @accredited_body ||= build(:provider, :accredited_body,
                               recruitment_cycle: current_recruitment_cycle)
  end

  def accredited_body_with_no_allocation
    @accredited_body_with_no_allocation ||= build(:provider, :accredited_body,
                                                  recruitment_cycle: current_recruitment_cycle)
  end

  def training_provider
    @training_provider ||= build(:provider, recruitment_cycle: current_recruitment_cycle)
  end

  def user_with_accredited_bodies
    @user_with_accredited_bodies ||= create(:user, providers:
      [accredited_body_with_allocation, accredited_body_with_no_allocation])
  end

  def next_allocation_cycle_period_text
    "#{Settings.allocation_cycle_year + 1} to #{Settings.allocation_cycle_year + 2}"
  end

  def and_an_allocation_exists_assigned_to_accredited_body
    allocation
  end

  def when_i_visit_allocations_page(provider)
    allocations_page.load(provider_code: provider.provider_code,
                          recruitment_cycle_year: provider.recruitment_cycle_year)
  end

  def then_it_has_the_correct_no_allocations_message
    expect(allocations_page).to have_content(
      "You did not request any allocations for fee-funded PE courses for #{next_allocation_cycle_period_text}",
    )
  end

  def then_it_has_the_correct_allocations_content
    expect(allocations_page.rows.first.provider_name.text).to eq(training_provider.provider_name)
    expect(allocations_page.rows.first.allocation_number.text.to_i).to eq(allocation.confirmed_number_of_places)
    expect(allocations_page.rows.first.uplift_number.text.to_i).to eq(allocation.allocation_uplift.uplifts)
  end

  def allocation
    @allocation ||= create(
      :allocation,
      :with_allocation_uplift,
      :repeat,
      accredited_body: accredited_body_with_allocation,
      provider: training_provider,
      number_of_places: 3,
      confirmed_number_of_places: 10,
    )
  end
end
