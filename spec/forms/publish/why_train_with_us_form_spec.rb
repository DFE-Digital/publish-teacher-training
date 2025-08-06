# frozen_string_literal: true

require "rails_helper"

module Publish
  describe WhyTrainWithUsForm, type: :model do
    include Rails.application.routes.url_helpers
    let(:params) do
      {
        about_us:,
        value_proposition:,
      }
    end
    let(:about_us) { "about_us" }
    let(:value_proposition) { "value_proposition" }
    let(:provider) { create(:provider) }
    let(:redirect_params) { { "goto_provider" => "true" } }
    let(:course_code) { create(:course) }

    subject { described_class.new(provider, params:, redirect_params:, course_code:) }

    context "validations" do
      it { is_expected.to validate_presence_of(:about_us).with_message("Enter what kind of organisation you are") }
      it { is_expected.to validate_presence_of(:value_proposition).with_message("Enter why candidates should choose to train with you") }

      context "traing_with_us word count is invalid" do
        let(:about_us) { Faker::Lorem.sentence(word_count: 101) }

        it "is not valid when traing_with_us is over 100 words" do
          expect(subject.valid?).to be_falsey
          expect(subject.errors[:about_us]).to include("'What kind of organisation is yours?' must be 100 words or less")
        end
      end

      context "value_proposition word count is invalid" do
        let(:value_proposition) { Faker::Lorem.sentence(word_count: 101) }

        it "is not valid when value_proposition is over 100 words" do
          expect(subject.valid?).to be_falsey
          expect(subject.errors[:value_proposition]).to include("'Why should candidates choose to train with you?' must be 100 words or less")
        end
      end
    end

    describe "#update_success_path" do
      context "when goto_provider is true" do
        let(:redirect_params) { { "goto_provider" => "true" } }

        it "returns the goto_provider path" do
          expect(subject.update_success_path).to eq(
            provider_publish_provider_recruitment_cycle_course_path(
              provider.provider_code,
              provider.recruitment_cycle_year,
              course_code,
            ),
          )
        end
      end

      context "when there is no redirect_params" do
        let(:redirect_params) { {} }

        it "returns the details path" do
          expect(subject.update_success_path).to eq(
            details_publish_provider_recruitment_cycle_path(
              provider.provider_code,
              provider.recruitment_cycle_year,
            ),
          )
        end
      end
    end
  end
end
