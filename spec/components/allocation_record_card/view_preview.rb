# frozen_string_literal: true

module AllocationRecordCard
  class ViewPreview < ViewComponent::Preview
    def single_card
      render(AllocationRecordCard::View.new(allocation: mock_allocation))
    end

    def multiple_cards
      render(AllocationRecordCard::View.with_collection(mock_multiple_allocations))
    end

  private

    def mock_allocation
      @mock_allocation ||= FactoryBot.create(:allocation, :with_allocation_uplift, number_of_places: 5)
    end

    def mock_multiple_allocations
      @mock_multiple_allocations ||= FactoryBot.create_list(:allocation, 3, number_of_places: 5)
    end
  end
end
