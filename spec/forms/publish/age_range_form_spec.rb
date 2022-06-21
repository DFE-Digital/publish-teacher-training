# frozen_string_literal: true

require "rails_helper"

module Publish
  describe AgeRangeForm, type: :model do
    let(:params) { { age_range_in_years: "10_to_20" } }
    let(:course) { build(:course) }

    subject { described_class.new(course, params:) }

    describe "#new" do
      context "when a custom age_range" do
        it "populates from and to and sets as other" do
          expect(subject.age_range_in_years).to eql("other")
          expect(subject.course_age_range_in_years_other_from).to be(10)
          expect(subject.course_age_range_in_years_other_to).to be(20)
        end
      end

      context "when a preset age_range" do
        let(:params) { { age_range_in_years: "3_to_7" } }

        it "uses preset value" do
          expect(subject.age_range_in_years).to eql("3_to_7")
          expect(subject.course_age_range_in_years_other_from).to be_nil
          expect(subject.course_age_range_in_years_other_to).to be_nil
        end
      end
    end

    describe "validations" do
      context "when age_range_in_years not selected" do
        let(:params) { { age_range_in_years: nil } }

        it "is not valid" do
          expect(subject).not_to be_valid
        end
      end

      context "when age_range_in_years is other" do
        context "and from years is not present" do
          let(:params) {
            {
              age_range_in_years: "other",
              course_age_range_in_years_other_from: nil,
              course_age_range_in_years_other_to: "10",
            }
          }

          it "is not valid" do
            expect(subject).not_to be_valid
          end
        end

        context "and to years is not present" do
          let(:params) {
            {
              age_range_in_years: "other",
              course_age_range_in_years_other_from: "10",
              course_age_range_in_years_other_to: nil,
            }
          }

          it "is not valid" do
            expect(subject).not_to be_valid
          end
        end

        context "when from is bigger than to age" do
          let(:params) {
            {
              age_range_in_years: "other",
              course_age_range_in_years_other_from: "11",
              course_age_range_in_years_other_to: "10",
            }
          }

          it "is not valid" do
            expect(subject).not_to be_valid
          end
        end

        context "when custom age range is less than 4 years" do
          let(:params) {
            {
              age_range_in_years: "other",
              course_age_range_in_years_other_from: "10",
              course_age_range_in_years_other_to: "11",
            }
          }

          it "is not valid" do
            expect(subject).not_to be_valid
          end
        end

        context "when from age is outside allowed range" do
          let(:params) {
            {
              age_range_in_years: "other",
              course_age_range_in_years_other_from: "47",
              course_age_range_in_years_other_to: "49",
            }
          }

          it "is not valid" do
            expect(subject).not_to be_valid
            expect(subject.errors[:course_age_range_in_years_other_from]).to include("From age must be between 0 and 46")
          end
        end

        context "when to age is outside allowed range" do
          let(:params) {
            {
              age_range_in_years: "other",
              course_age_range_in_years_other_from: "10",
              course_age_range_in_years_other_to: "51",
            }
          }

          it "is not valid" do
            expect(subject.valid?).to be_falsey
            expect(subject.errors[:course_age_range_in_years_other_to]).to include("To age must be between 4 and 50")
          end
        end
      end
    end
  end
end
