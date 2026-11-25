# frozen_string_literal: true

require "rails_helper"

module Support
  describe UpdateProviderForm, type: :model do
    let(:provider) { create(:provider, :accredited_provider) }
    let(:update_provider_form) { described_class.new(provider, attributes:) }
    let(:attributes) { attributes_for(:provider, :accredited_provider) }

    subject { update_provider_form }

    describe "#save" do
      context "provider is changed from accredited_provider to not accredited_provider" do
        let(:attributes) { { accredited: false } }

        it "removes the accredited_provider_number" do
          expect { subject.save }.to change(provider.reload, :accredited_provider_number).from(provider.accredited_provider_number).to(nil)
        end
      end

      context "provider code" do
        let(:attributes) { { provider_code: } }
        let(:provider_code) { "Z99" }

        before { provider.update!(provider_code: "Q10") }

        it "saves a new provider code" do
          expect(subject.save).to be_truthy
          expect(subject.provider_code_updated?).to be true
          expect(provider.reload.provider_code).to eq("Z99")
        end

        it "allows the provider to keep its current code" do
          provider.update!(provider_code: "Z99")
          expect(subject.save).to be_truthy
          expect(subject.provider_code_updated?).to be false
        end

        it "allows a code used by a provider in another recruitment cycle" do
          create(:provider, :next_recruitment_cycle, provider_code: "Z99")

          expect(subject.save).to be_truthy
          expect(provider.reload.provider_code).to eq("Z99")
        end

        it "does not save a code already used in this recruitment cycle" do
          create(:provider, recruitment_cycle: provider.recruitment_cycle, provider_code: "Z99")

          expect(subject.save).to be_falsey
          expect(provider.reload.provider_code).not_to eq("Z99")
          expect(provider.errors[:provider_code]).to eq(["Provider code already in use. Enter a new provider code"])
        end

        it "does not save a code used by a discarded provider in this recruitment cycle" do
          create(:provider, :discarded, recruitment_cycle: provider.recruitment_cycle, provider_code: "Z99")

          expect(subject.save).to be_falsey
          expect(provider.errors[:provider_code]).to eq(["Provider code already in use. Enter a new provider code"])
        end

        it "does not save a code that is not 3 characters" do
          invalid_form = described_class.new(provider, attributes: { provider_code: "Z9" })

          expect(invalid_form.save).to be_falsey
          expect(provider.errors[:provider_code]).to eq(["Provider code must be 3 characters"])
        end

        it "does not save a code with the wrong format" do
          invalid_form = described_class.new(provider, attributes: { provider_code: "abc" })

          expect(invalid_form.save).to be_falsey
          expect(provider.errors[:provider_code]).to eq(
            ["Enter a valid provider code. It must be exactly 3 characters with at least one number. All letters must be in upper case."],
          )
          expect(invalid_form.submitted_provider_code).to eq("abc")
        end
      end
    end
  end
end
