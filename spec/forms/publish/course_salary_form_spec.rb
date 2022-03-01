# frozen_string_literal: true

require "rails_helper"

module Publish
  describe CourseSalaryForm, type: :model do
    let(:params) { {} }
    let(:course) { build(:course, :salary_type_based) }
    let(:enrichment) { course.enrichments.find_or_initialize_draft }

    subject { described_class.new(enrichment, params: params) }

    describe "validations" do
      it { is_expected.to validate_presence_of(:course_length) }

      context "salary details" do
        before do
          enrichment.salary_details = Faker::Lorem.sentence(word_count: 251)
          subject.valid?
        end

        it "validates the word count for fee details" do
          expect(subject).not_to be_valid
          expect(subject.errors[:salary_details])
            .to include(I18n.t("activemodel.errors.models.publish/course_salary_form.attributes.salary_details.too_long"))
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
      let(:params) { { course_length: "some new value", salary_details: "some text" } }

      before do
        enrichment.salary_details = Faker::Lorem.sentence(word_count: 249)
        enrichment.course_length = nil
      end

      it "saves the provider with any new attributes" do
        expect { subject.save! }.to change(enrichment, :course_length).from(nil).to("some new value")
        .and change(enrichment, :salary_details).to("some text")
      end
    end
  end
end
