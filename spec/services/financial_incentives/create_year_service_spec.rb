# frozen_string_literal: true

require "rails_helper"

RSpec.describe FinancialIncentives::CreateYearService, :without_subjects do
  subject(:create_year) { described_class.call(year: target_year) }

  let(:source_year) { 2025 }
  let(:target_year) { 2026 }
  let(:subject_with_displayed_incentive) { create(:primary_subject, :primary) }
  let(:subject_without_incentive) { create(:primary_subject, :primary_with_english) }
  let(:discontinued_subject) { create(:discontinued_subject, :humanities) }

  describe ".call" do
    before do
      given_subject_areas_exist
      and_subjects_exist
    end

    context "when the target year has no financial incentives" do
      before do
        given_the_subject_has_a_displayed_incentive
      end

      it "creates hidden target-year records for active subjects" do
        expect { @created_count = create_year }
          .to change(target_year_incentives, :count).by(2)

        expect(@created_count).to eq(2)
        expect(copied_incentive).to have_attributes(copied_incentive_attributes)
        expect(blank_incentive).to have_attributes(blank_incentive_attributes)
        expect(discontinued_target_year_incentives).to be_empty
      end
    end

    context "when an active subject already has a target-year incentive" do
      before do
        create(:financial_incentive, :hidden, subject: subject_with_displayed_incentive, year: target_year)
      end

      it "does not overwrite the year" do
        expect { create_year }
          .to raise_error(described_class::YearAlreadyExistsError)

        expect(target_year_incentives.count).to eq(1)
      end
    end
  end

private

  def given_subject_areas_exist
    find_or_create(:subject_area, :primary)
    find_or_create(:subject_area, :discontinued)
  end

  def and_subjects_exist
    subject_with_displayed_incentive
    subject_without_incentive
    discontinued_subject
  end

  def given_the_subject_has_a_displayed_incentive
    create(:financial_incentive, displayed_incentive_attributes)
  end

  def displayed_incentive_attributes
    copied_incentive_attributes.merge(
      subject: subject_with_displayed_incentive,
      year: source_year,
      displayed: true,
    )
  end

  def copied_incentive
    subject_with_displayed_incentive.financial_incentive_records.find_by!(year: target_year)
  end

  def blank_incentive
    subject_without_incentive.financial_incentive_records.find_by!(year: target_year)
  end

  def target_year_incentives
    FinancialIncentive.for_year(target_year)
  end

  def discontinued_target_year_incentives
    discontinued_subject.financial_incentive_records.for_year(target_year)
  end

  def copied_incentive_attributes
    {
      bursary_amount: "10000",
      scholarship: "12000",
      early_career_payments: "2000",
      non_uk_bursary_eligible: true,
      non_uk_scholarship_eligible: true,
      subject_knowledge_enhancement_course_available: true,
      displayed: false,
    }
  end

  def blank_incentive_attributes
    FinancialIncentive::DEFAULT_ATTRIBUTES.merge(displayed: false)
  end
end
