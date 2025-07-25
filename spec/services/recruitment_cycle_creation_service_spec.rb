# frozen_string_literal: true

require "rails_helper"

describe RecruitmentCycleCreationService do
  describe ".call" do
    subject(:service) do
      described_class.call(
        year:,
        application_start_date:,
        application_end_date:,
        available_for_support_users_from:,
        available_in_publish_from:,
      )
    end

    let(:year) { 2030 }
    let(:application_start_date) { Date.new(2031, 9, 1) }
    let(:application_end_date) { Date.new(2032, 9, 1) }
    let(:available_for_support_users_from) { Date.new(2032, 6, 1) }
    let(:available_in_publish_from) { Date.new(2032, 7, 1) }

    context "when creation succeeds" do
      it "creates a recruitment cycle with correct attributes" do
        expect { service }.to change(RecruitmentCycle, :count).by(1)

        recruitment_cycle = RecruitmentCycle.last
        expect(recruitment_cycle.year.to_i).to eq(year)
        expect(recruitment_cycle.application_start_date).to eq(application_start_date)
        expect(recruitment_cycle.application_end_date).to eq(application_end_date)
        expect(recruitment_cycle.available_for_support_users_from).to eq(available_for_support_users_from)
        expect(recruitment_cycle.available_in_publish_from).to eq(available_in_publish_from)
      end
    end

    context "when creation fails" do
      before do
        allow(RecruitmentCycle).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(RecruitmentCycle.new))
      end

      it "does not create a recruitment cycle" do
        RecruitmentCycle.delete_all

        expect { service }.to raise_error(ActiveRecord::RecordInvalid)
        expect(RecruitmentCycle.count).to eq(0)
      end
    end
  end
end
