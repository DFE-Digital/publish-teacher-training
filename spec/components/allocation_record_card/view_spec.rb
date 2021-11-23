# frozen_string_literal: true

require "rails_helper"

module AllocationRecordCard
  describe View do
    alias_method :component, :page

    let(:allocation) { create(:allocation, :with_allocation_uplift, number_of_places: 5) }
    let(:provider) { allocation.provider }
    let(:accredited_body) { allocation.accredited_body }

    before do
      render_inline(described_class.new(allocation: allocation))
    end

    it "renders all the correct details" do
      expect(component).to have_text(provider.provider_name)
      expect(component).to have_text(provider.provider_code)
      expect(component).to have_text(allocation.confirmed_number_of_places)
      expect(component).to have_text(allocation.allocation_uplift.uplifts&.to_i)
      expect(component).to have_text(accredited_body.provider_name)
      expect(component).to have_text(accredited_body.provider_code)
    end
  end
end
