# frozen_string_literal: true

require "rails_helper"

module Publish
  describe WhyTrainWithUsForm, type: :model do
    include Rails.application.routes.url_helpers
    let(:params) do
      {
        about_us:,
        provider_value_proposition:,
      }
    end
    let(:about_us) { "about_us" }
    let(:provider_value_proposition) { "provider_value_proposition" }
    let(:provider) { create(:provider) }
    let(:redirect_params) { { "goto_provider" => "true" } }
    let(:course_code) { create(:course) }

    subject { described_class.new(provider, params:, redirect_params:, course_code:) }

    context "validations" do
      it { is_expected.to validate_presence_of(:about_us).with_message("Enter details about your organisation") }
      it { is_expected.to validate_presence_of(:provider_value_proposition).with_message("Enter details about training with you") }

      context "traing_with_us word count is invalid" do
        let(:about_us) { Faker::Lorem.sentence(word_count: 101) }

        it "is not valid when traing_with_us is over 100 words" do
          expect(subject.valid?).to be_falsey
          expect(subject.errors[:about_us]).to include("Reduce the word count for about us")
        end
      end

      context "provider_value_proposition word count is invalid" do
        let(:provider_value_proposition) { Faker::Lorem.sentence(word_count: 101) }

        it "is not valid when provider_value_proposition is over 100 words" do
          expect(subject.valid?).to be_falsey
          expect(subject.errors[:provider_value_proposition]).to include("Reduce the word count for your value proposition")
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
