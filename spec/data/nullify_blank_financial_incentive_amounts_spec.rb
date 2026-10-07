# frozen_string_literal: true

require "rails_helper"
require Rails.root.join("db/data/20261007120000_nullify_blank_financial_incentive_amounts")

describe NullifyBlankFinancialIncentiveAmounts do
  it "replaces blank incentive amounts with nil and leaves amounts alone" do
    financial_incentive = create(:secondary_subject, bursary_amount: "29000").financial_incentive
    FinancialIncentive.connection.exec_update(
      "UPDATE financial_incentive SET scholarship = '', early_career_payments = E'\\t ' WHERE id = #{financial_incentive.id}",
    )

    described_class.new.up

    expect(financial_incentive.reload.attributes.slice("bursary_amount", "scholarship", "early_career_payments"))
      .to eq("bursary_amount" => "29000", "scholarship" => nil, "early_career_payments" => nil)
  end
end
