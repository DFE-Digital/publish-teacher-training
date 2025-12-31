# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Fields::FeesAndFinancialSupportForm, type: :model do
  subject(:form) { described_class.new(enrichment, params:) }

  let(:params) { {} }

  context "when course is fee based and can sponsor student visas" do
    let(:course) { create(:course, :fee_type_based, funding: "fee", can_sponsor_student_visa: true) }
    let(:enrichment) { create(:course_enrichment, :initial_draft, :without_content, course:) }

    it "requires fee_uk_eu to be present" do
      form.validate
      expect(form.errors[:fee_uk_eu]).to include("Enter fee for UK citizens")
    end

    it "requires fee_international to be present when course can sponsor student visas" do
      form.validate
      expect(form.errors[:fee_international]).to include("Enter fee for non-UK citizens")
    end

    it "validates integer values for fees and upper bound" do
      params.merge!(fee_uk_eu: "100.50", fee_international: 100_001)
      form.validate

      expect(form.errors[:fee_uk_eu]).to include("Course fee for UK citizens must not include pence, like 1000 or 1500")
      expect(form.errors[:fee_international]).to include("Course fee for non-UK citizens must be less than or equal to £100,000")
    end

    it "validates not a number for international fee" do
      params.merge!(fee_uk_eu: 1000, fee_international: "abc")
      form.validate
      expect(form.errors[:fee_international]).to include("Course fee for non-UK citizens must be a valid number")
    end
  end

  context "when course is salary based" do
    let(:course) { create(:course, :with_salary, funding: "salary") }
    let(:enrichment) { create(:course_enrichment, :initial_draft, course:) }

    it "does not require fee fields" do
      form.validate
      expect(form.errors[:fee_uk_eu]).to be_empty
      expect(form.errors[:fee_international]).to be_empty
    end

    it "validates word counts for schedule, additional fees and financial support" do
      params.merge!(
        fee_schedule: Faker::Lorem.words(number: 51).join(" "),
        additional_fees: Faker::Lorem.words(number: 51).join(" "),
        financial_support: Faker::Lorem.words(number: 51).join(" "),
      )
      form.validate

      expect(form.errors[:fee_schedule]).to include("Fee schedule must be 50 words or less")
      expect(form.errors[:additional_fees]).to include("Additional fees must be 50 words or less")
      expect(form.errors[:financial_support]).to include("Financial support must be 50 words or less")
    end
  end
end
