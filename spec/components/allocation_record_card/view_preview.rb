# frozen_string_literal: true

module AllocationRecordCard
  class ViewPreview < ViewComponent::Preview
    def multiple_cards
      render(AllocationRecordCard::View.with_collection(multiple_allocations, recruitment_cycle_year: Settings.current_recruitment_cycle_year))
    end

  private

    def multiple_allocations
      [
        Allocation.new(
          id: 1,
          confirmed_number_of_places: 3,
          provider:,
          accredited_body:,
          allocation_uplift:,
        ),
        Allocation.new(
          id: 2,
          confirmed_number_of_places: 5,
          provider:,
          accredited_body:,
          allocation_uplift:,
        ),
      ]
    end

    def provider
      @provider ||= Provider.new(
        provider_code: "HC7",
        provider_name: "Hogwarts School of Witchcraft and Wizardry",
      )
    end

    def accredited_body
      @accredited_body ||= Provider.new(
        provider_code: "SP1",
        provider_name: "South Park Elementary",
      )
    end

    def allocation_uplift
      @allocation_uplift ||= AllocationUplift.new(
        uplifts: 4,
      )
    end
  end
end
