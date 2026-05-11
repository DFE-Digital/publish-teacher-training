# frozen_string_literal: true

require "rails_helper"

describe Subjects::FinancialIncentiveCreatorService, :without_subjects do
  before do
    find_or_create(:subject_area, :secondary)
  end

  it "creates hidden financial incentives for the requested year" do
    physics = create(:secondary_subject, :physics)
    FinancialIncentive.where(subject: physics).delete_all

    described_class.new(year: 2026).execute

    financial_incentive = physics.financial_incentive_records.find_by!(year: 2026)
    expect(financial_incentive).to have_attributes(
      bursary_amount: "29000",
      scholarship: "31000",
      displayed: false,
    )
  end

  it "does not reset financial incentives from other years" do
    physics = create(:secondary_subject, :physics)
    FinancialIncentive.where(subject: physics).delete_all
    previous_year_incentive = create(
      :financial_incentive,
      subject: physics,
      year: 2025,
      bursary_amount: "1",
      scholarship: "2",
      displayed: true,
    )

    described_class.new(year: 2026).execute

    expect(previous_year_incentive.reload).to have_attributes(
      bursary_amount: "1",
      scholarship: "2",
      displayed: true,
    )
  end

  it "updates existing financial incentives for the requested year with the year's values" do
    chemistry = create(:secondary_subject, :chemistry)
    FinancialIncentive.where(subject: chemistry).delete_all
    financial_incentive = create(
      :financial_incentive,
      subject: chemistry,
      year: 2026,
      bursary_amount: "1",
      scholarship: nil,
      non_uk_bursary_eligible: true,
      displayed: false,
    )

    described_class.new(year: 2026).execute

    expect(financial_incentive.reload).to have_attributes(
      bursary_amount: "29000",
      scholarship: "31000",
      non_uk_bursary_eligible: false,
      displayed: false,
    )
  end

  it "resets unmentioned financial incentives from the requested year but preserves display state" do
    art_and_design = create(:secondary_subject, :art_and_design, financial_incentive_year: 2026)
    financial_incentive = art_and_design.financial_incentive_records.find_by!(year: 2026)
    financial_incentive.update!(
      bursary_amount: "1",
      scholarship: "2",
      non_uk_bursary_eligible: true,
      non_uk_scholarship_eligible: true,
      displayed: true,
    )

    described_class.new(year: 2026).execute

    expect(financial_incentive.reload).to have_attributes(
      bursary_amount: nil,
      scholarship: nil,
      non_uk_bursary_eligible: false,
      non_uk_scholarship_eligible: false,
      displayed: true,
    )
  end

  it "does not hide an existing displayed financial incentive by default" do
    physics = create(:secondary_subject, :physics, financial_incentive_year: 2026, financial_incentive_displayed: true)
    financial_incentive = physics.financial_incentive_records.find_by!(year: 2026)

    described_class.new(year: 2026).execute

    expect(financial_incentive.reload).to be_displayed
  end

  it "can create displayed financial incentives when requested" do
    physics = create(:secondary_subject, :physics)
    FinancialIncentive.where(subject: physics).delete_all

    described_class.new(year: 2026, displayed: true).execute

    expect(physics.financial_incentive_records.find_by!(year: 2026)).to be_displayed
  end

  it "displays the requested year's financial incentive and hides the previous displayed incentive" do
    physics = create(:secondary_subject, :physics)
    FinancialIncentive.where(subject: physics).delete_all
    previous_year_incentive = create(:financial_incentive, subject: physics, year: 2025, displayed: true)
    requested_year_incentive = create(:financial_incentive, :hidden, subject: physics, year: 2026)

    described_class.new(year: 2026, displayed: true).execute

    expect(requested_year_incentive.reload).to be_displayed
    expect(previous_year_incentive.reload).not_to be_displayed
  end
end
