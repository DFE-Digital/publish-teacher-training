# frozen_string_literal: true

require "rails_helper"

RSpec.describe FinancialIncentives::CreateMissingService, :without_subjects do
  subject(:create_missing) { described_class.call(**service_arguments) }

  let(:target_year) { 2026 }
  let(:service_arguments) { { year: target_year } }
  let(:existing_subject) { create(:primary_subject, :primary) }
  let(:missing_subject) { create(:primary_subject, :primary_with_english) }
  let(:discontinued_subject) { create(:discontinued_subject, :humanities) }

  describe ".call" do
    before do
      given_subject_areas_exist
      and_subjects_exist
    end

    context "when an existing year is missing incentives for active subjects" do
      before do
        given_one_active_subject_already_has_an_incentive
      end

      it "creates blank hidden incentives only for the missing active subjects" do
        expect { @created_count = create_missing }
          .to change(target_year_incentives, :count).by(1)

        expect(@created_count).to eq(1)
        expect(missing_incentive).to have_attributes(blank_incentive_attributes)
        expect(existing_subject_target_year_incentives.count).to eq(1)
        expect(discontinued_target_year_incentives).to be_empty
      end
    end

    context "when repairing one active subject" do
      let(:service_arguments) { { year: target_year, subject: missing_subject } }

      it "creates a blank hidden incentive for only that subject" do
        expect { @created_count = create_missing }
          .to change(target_year_incentives, :count).by(1)

        expect(@created_count).to eq(1)
        expect(missing_incentive).to have_attributes(blank_incentive_attributes)
        expect(existing_subject_target_year_incentives).to be_empty
      end
    end
  end

private

  def given_subject_areas_exist
    find_or_create(:subject_area, :primary)
    find_or_create(:subject_area, :discontinued)
  end

  def and_subjects_exist
    existing_subject
    missing_subject
    discontinued_subject
  end

  def given_one_active_subject_already_has_an_incentive
    create(:financial_incentive, :hidden, subject: existing_subject, year: target_year)
  end

  def missing_incentive
    missing_subject.financial_incentive_records.find_by!(year: target_year)
  end

  def target_year_incentives
    FinancialIncentive.for_year(target_year)
  end

  def existing_subject_target_year_incentives
    existing_subject.financial_incentive_records.for_year(target_year)
  end

  def discontinued_target_year_incentives
    discontinued_subject.financial_incentive_records.for_year(target_year)
  end

  def blank_incentive_attributes
    FinancialIncentive::DEFAULT_ATTRIBUTES.merge(displayed: false)
  end
end
