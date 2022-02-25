# frozen_string_literal: true

require "rails_helper"

module Publish
  describe CourseFeeForm, type: :model do
    let(:params) { {} }
    let(:course) { build(:course, :fee_type_based) }
    let(:enrichment) { course.enrichments.find_or_initialize_draft }

    subject { described_class.new(enrichment, params: params) }

    describe "validations" do
      it { is_expected.to validate_presence_of(:course_length) }
      it { is_expected.to validate_presence_of(:fee_uk_eu) }

      it "validates UK/EU Fee" do
        expect(subject).to validate_numericality_of(:fee_uk_eu)
          .only_integer
          .is_greater_than_or_equal_to(0)
          .is_less_than_or_equal_to(100000)
          .allow_nil
      end

      it "validates International Fee" do
        expect(subject).to validate_numericality_of(:fee_international)
          .only_integer
          .is_greater_than_or_equal_to(0)
          .is_less_than_or_equal_to(100000)
          .allow_nil
      end

      context "fee details" do
        before do
          enrichment.fee_details = Faker::Lorem.sentence(word_count: 251)
          subject.valid?
        end

        it "validates the word count for fee details" do
          expect(subject).not_to be_valid
          expect(subject.errors[:fee_details])
            .to include(I18n.t("activemodel.errors.models.publish/course_fee_form.attributes.fee_details.too_long"))
        end
      end

      context "financial support" do
        before do
          enrichment.financial_support = Faker::Lorem.sentence(word_count: 251)
          subject.valid?
        end

        it "validates the word count for financial support" do
          expect(subject).not_to be_valid
          expect(subject.errors[:financial_support])
            .to include(I18n.t("activemodel.errors.models.publish/course_fee_form.attributes.financial_support.too_long"))
        end
      end
    end

    context "hydrating user set course length value" do
      before do
        enrichment.course_length = "some user length"
      end

      it "sets the course length value to other length" do
        expect(subject.course_length).to eq("Other")
      end

      it "sets the course length other length value to the user input" do
        expect(subject.course_length_other_length).to eq("some user length")
      end
    end

    describe "#other_course_length?" do
      before do
        enrichment.course_length = "some length"
      end

      it "returns true if value is user set" do
        expect(subject.other_course_length?).to be_truthy
      end
    end

    describe "#save!" do
      let(:params) { { course_length: "some new value", fee_uk_eu: 12_000 } }

      before do
        enrichment.fee_uk_eu = 9500
        enrichment.course_length = "OneYear"
      end

      it "saves the provider with any new attributes" do
        expect { subject.save! }.to change(enrichment, :course_length).from("OneYear").to("some new value")
        .and change(enrichment, :fee_uk_eu).from(9500).to(12_000)
      end
    end
  end
end
