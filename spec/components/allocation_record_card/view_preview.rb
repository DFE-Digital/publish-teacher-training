# frozen_string_literal: true

module AllocationRecordCard
  class ViewPreview < ViewComponent::Preview
    def multiple_cards
      render(AllocationRecordCard::View.with_collection(multiple_allocations))
    end

  private

    def multiple_allocations
      @multiple_allocations ||= FactoryBot.create_list(:allocation, 3, number_of_places: 5)
    end
  end
end
