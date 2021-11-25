# frozen_string_literal: true

module AllocationRecordCard
  class ViewPreview < ViewComponent::Preview
    def multiple_cards
      render(AllocationRecordCard::View.with_collection(multiple_allocations))
    end

  private

    def multiple_allocations
      [
        OpenStruct.new(
          id: 1,
          confirmed_number_of_places: 3,
          provider: provider,
          accredited_body: accredited_body,
          allocation_uplift: allocation_uplift,
        ),
        OpenStruct.new(
          id: 2,
          confirmed_number_of_places: 5,
          provider: provider,
          accredited_body: accredited_body,
          allocation_uplift: allocation_uplift,
        ),
      ]
    end

    def provider
      @provider ||= OpenStruct.new(
        provider_code: "HC7",
        provider_name: "Hogwarts School of Witchcraft and Wizardry",
      )
    end

    def accredited_body
      @accredited_body ||= OpenStruct.new(
        provider_code: "SP1",
        provider_name: "South Park Elementary",
      )
    end

    def allocation_uplift
      @allocation_uplift ||= OpenStruct.new(
        uplifts: 4,
      )
    end
  end
end
