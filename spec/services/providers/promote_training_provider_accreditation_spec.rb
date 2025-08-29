require "rails_helper"

module Providers
  RSpec.describe PromoteTrainingProviderAccreditation do
    let(:accrediting_provider) { create(:accredited_provider) }
    let(:training_provider) do
      create(
        :provider,
        provider_type:,
        courses: [create(:course, accrediting_provider:)],
      )
    end
    let(:accredited_provider_number) { 5432 }
    let(:provider_type) { :lead_school }

    context "when training provider is HEI" do
      let(:provider_type) { :university }
      let(:accredited_provider_number) { 1432 }

      context "when training provider is School" do
        describe "provider has courses accredited by accredited provider" do
          it "changes `accredited` to true" do
            expect {
              described_class.new(training_provider, accredited_provider_number).call
            }.to change { training_provider.reload.accredited }.from(false).to(true)
          end

          it "changes sets accredited_provider_code to nil for all courses" do
            course = training_provider.courses.first
            expect {
              described_class.new(training_provider, accredited_provider_number).call
            }.to change { course.accredited_provider_code }.from(accrediting_provider.provider_code).to(nil)
          end

          it "updates the accredited_provider_number" do
            expect {
              described_class.new(training_provider, accredited_provider_number).call
            }.to change(training_provider, :accredited_provider_number).from(nil).to(accredited_provider_number)
          end
        end
      end
    end

    context "when training provider is School" do
      describe "provider has courses accredited by accredited provider" do
        it "changes `accredited` to true" do
          expect {
            described_class.new(training_provider, accredited_provider_number).call
          }.to change { training_provider.reload.accredited }.from(false).to(true)
        end

        it "changes sets accredited_provider_code to nil for all courses" do
          course = training_provider.courses.first
          expect {
            described_class.new(training_provider, accredited_provider_number).call
          }.to change { course.accredited_provider_code }.from(accrediting_provider.provider_code).to(nil)
        end

        it "updates the accredited_provider_number" do
          expect {
            described_class.new(training_provider, accredited_provider_number).call
          }.to change(training_provider, :accredited_provider_number).from(nil).to(accredited_provider_number)
        end
      end
    end
  end
end
