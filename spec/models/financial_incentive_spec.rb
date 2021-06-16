require "rails_helper"

describe FinancialIncentive, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:subject) }
  end
end
