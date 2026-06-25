# frozen_string_literal: true

require "rails_helper"

module Publish
  describe CourseSalaryFeesForm, type: :model do
    subject { described_class.new(enrichment, params:) }

    let(:params) { {} }
    let(:course) { build(:course, :salary_type_based) }
    let(:enrichment) { course.enrichments.find_or_initialize_draft }

    describe "validations" do
      context "when salary fee details are within the word limit" do
        before do
          enrichment.salary_fee_details = Faker::Lorem.sentence(word_count: 250)
        end

        it "is valid" do
          expect(subject).to be_valid
        end
      end

      context "when salary fee details exceed the word limit" do
        before do
          enrichment.salary_fee_details = Faker::Lorem.sentence(word_count: 251)
          subject.valid?
        end

        it "adds a too_long error" do
          expect(subject).not_to be_valid
          expect(subject.errors[:salary_fee_details]).to include("Reduce the word count for fees")
        end
      end

      context "when salary fee details are blank" do
        before do
          enrichment.salary_fee_details = nil
        end

        it "is valid as the field is optional" do
          expect(subject).to be_valid
        end
      end
    end

    describe "#save!" do
      let(:params) { { salary_fee_details: "some fees text" } }

      it "saves the enrichment with the new attributes" do
        expect { subject.save! }.to change(enrichment, :salary_fee_details).to("some fees text")
      end
    end
  end
end
