require "rails_helper"

RSpec.describe AllocationUplift, type: :model do
  let(:provider) { create(:provider, :accredited_body) }
  let(:recruitment_cycle) { create(:recruitment_cycle) }
  let(:allocation) { create(:allocation, number_of_places: 1, provider: provider, recruitment_cycle: recruitment_cycle) }
  let(:allocation_uplift) { create(:allocation_uplift, allocation: allocation) }

  it { is_expected.to belong_to(:allocation) }

  context "forwardable methods" do
    it "has methods forwarded to allocation" do
      expect(allocation_uplift.provider).to eq provider
      expect(allocation_uplift.recruitment_cycle).to eq recruitment_cycle
    end
  end
end
