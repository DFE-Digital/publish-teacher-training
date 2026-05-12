# frozen_string_literal: true

require "rails_helper"

RSpec.describe FinancialIncentives::PublishYearService, :without_subjects do
  subject(:publish_year) { described_class.call(year: target_year) }

  let(:previous_year) { 2025 }
  let(:target_year) { 2026 }
  let(:first_subject) { create(:primary_subject, :primary) }
  let(:second_subject) { create(:primary_subject, :primary_with_english) }
  let(:discontinued_subject) { create(:discontinued_subject, :humanities) }

  describe ".call" do
    before do
      given_subject_areas_exist
      and_subjects_exist
    end

    context "when the target year is complete" do
      before do
        given_the_previous_year_is_visible
        and_the_target_year_is_hidden_for_active_subjects
        and_a_discontinued_subject_has_a_hidden_target_year_incentive
      end

      it "switches visibility for active subjects only" do
        publish_year

        expect(first_target_incentive.reload).to be_displayed
        expect(second_target_incentive.reload).to be_displayed
        expect(first_previous_incentive.reload).not_to be_displayed
        expect(second_previous_incentive.reload).not_to be_displayed
        expect(discontinued_target_incentive.reload).not_to be_displayed
      end
    end

    context "when the target year is missing an active subject" do
      before do
        create(:financial_incentive, :hidden, subject: first_subject, year: target_year)
      end

      it "raises an error with the missing subjects" do
        expect { publish_year }
          .to raise_error(described_class::IncompleteYearError) do |error|
            expect(error.missing_subjects).to contain_exactly(second_subject)
          end
      end
    end
  end

private

  def given_subject_areas_exist
    find_or_create(:subject_area, :primary)
    find_or_create(:subject_area, :discontinued)
  end

  def and_subjects_exist
    first_subject
    second_subject
    discontinued_subject
  end

  def given_the_previous_year_is_visible
    create(:financial_incentive, subject: first_subject, year: previous_year, displayed: true)
    create(:financial_incentive, subject: second_subject, year: previous_year, displayed: true)
  end

  def and_the_target_year_is_hidden_for_active_subjects
    create(:financial_incentive, :hidden, subject: first_subject, year: target_year)
    create(:financial_incentive, :hidden, subject: second_subject, year: target_year)
  end

  def and_a_discontinued_subject_has_a_hidden_target_year_incentive
    create(:financial_incentive, :hidden, subject: discontinued_subject, year: target_year)
  end

  def first_previous_incentive
    financial_incentive_for(first_subject, previous_year)
  end

  def second_previous_incentive
    financial_incentive_for(second_subject, previous_year)
  end

  def first_target_incentive
    financial_incentive_for(first_subject, target_year)
  end

  def second_target_incentive
    financial_incentive_for(second_subject, target_year)
  end

  def discontinued_target_incentive
    financial_incentive_for(discontinued_subject, target_year)
  end

  def financial_incentive_for(subject, year)
    subject.financial_incentive_records.find_by!(year:)
  end
end
