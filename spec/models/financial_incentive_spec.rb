require "rails_helper"

describe FinancialIncentive, type: :model do
  describe "associations" do
    it { should belong_to(:subject) }
  end
end
