# frozen_string_literal: true

require "rails_helper"

RSpec.describe FinancialIncentiveHintHelper do
  describe "#bursary_value" do
    let(:helper_instance_class) do
      Struct.new(:course, :visa_sponsorship, keyword_init: true) do
        include FinancialIncentiveHintHelper
      end
    end

    let(:subject_with_incentives) { create(:secondary_subject, :chemistry, bursary_amount: 20_000, scholarship: 22_000) }

    let(:course) do
      create(
        :course,
        :secondary,
        :open,
        :published,
        provider: build(:provider),
        subjects: [subject_with_incentives],
        master_subject_id: subject_with_incentives.id,
      )
    end

    let(:instance) { helper_instance_class.new(course:, visa_sponsorship:) }
    let(:visa_sponsorship) { nil }

    before do
      FeatureFlag.activate(:bursaries_and_scholarships_announced)
    end

    after do
      FeatureFlag.deactivate(:bursaries_and_scholarships_announced)
    end

    it "appends 'for UK citizens' when subject is not non-UK eligible" do
      expect(instance.bursary_value).to eq("Scholarships of £22,000 or bursaries of £20,000 are available for UK citizens")
    end

    context "when visa sponsorship filtering is in effect (and the subject is not physics or languages)" do
      let(:visa_sponsorship) { "true" }

      it "hides the hint" do
        expect(instance.bursary_value).to be_nil
      end
    end

    context "when the feature flag is inactive" do
      before do
        FeatureFlag.deactivate(:bursaries_and_scholarships_announced)
      end

      it "hides the hint" do
        expect(instance.bursary_value).to be_nil
      end
    end

    context "when the course is salaried" do
      let(:course) do
        create(
          :course,
          :secondary,
          :open,
          :published,
          :salary,
          provider: build(:provider),
          subjects: [subject_with_incentives],
          master_subject_id: subject_with_incentives.id,
        )
      end

      it "returns nil" do
        expect(instance.bursary_value).to be_nil
      end
    end

    context "when visa sponsorship is active but subject has non-UK funding" do
      let(:visa_sponsorship) { "true" }
      let(:eligible_subject) { create(:secondary_subject, subject_name: "Physics", bursary_amount: 20_000, scholarship: 22_000, non_uk_bursary_eligible: true, non_uk_scholarship_eligible: true) }
      let(:course) do
        create(
          :course,
          :secondary,
          :open,
          :published,
          provider: build(:provider),
          subjects: [eligible_subject],
          master_subject_id: eligible_subject.id,
        )
      end

      it "shows the hint without 'for UK citizens'" do
        expect(instance.bursary_value).to eq("Scholarships of £22,000 or bursaries of £20,000 are available")
      end
    end
  end
end
