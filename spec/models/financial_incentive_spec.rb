# frozen_string_literal: true

require "rails_helper"

describe FinancialIncentive do
  describe "associations" do
    it { is_expected.to belong_to(:subject) }
  end

  describe "validations" do
    let(:subject_record) { find_or_create(:primary_subject, :primary) }

    before do
      described_class.where(subject: subject_record).delete_all
    end

    it "allows one financial incentive per subject per year" do
      create(:financial_incentive, :hidden, subject: subject_record, year: 2026)

      duplicate = build(:financial_incentive, :hidden, subject: subject_record, year: 2026)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:year]).to include("has already been taken")
    end

    it "allows only one displayed financial incentive per subject" do
      create(:financial_incentive, subject: subject_record, year: 2026, displayed: true)

      duplicate = build(:financial_incentive, subject: subject_record, year: 2027, displayed: true)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:displayed]).to include("has already been taken")
    end

    it "defaults new records to the current recruitment cycle year and hidden" do
      financial_incentive = described_class.new

      expect(financial_incentive.year).to eq(described_class.current_year)
      expect(financial_incentive).not_to be_displayed
    end
  end
end
