require "rails_helper"

RSpec.describe Partnerships::CopyToProviderService do
  let(:previous_cycle) { create(:recruitment_cycle) }
  let(:target_cycle) { create(:recruitment_cycle, :next) }
  let(:service) { described_class.new }

  describe "#execute" do
    let(:original_provider) { create(:provider, recruitment_cycle: previous_cycle, provider_code: "ORIG") }
    let(:rolled_over_provider) { create(:provider, recruitment_cycle: target_cycle, provider_code: "ORIG") }

    context "when partnership involves rolled-over provider as training provider" do
      let!(:partner_provider) { create(:provider, :accredited_provider, recruitment_cycle: previous_cycle, provider_code: "Accred") }
      let!(:target_partner) { create(:provider, :accredited_provider, recruitment_cycle: target_cycle, provider_code: "Accred") }
      let!(:partnership) do
        create(:provider_partnership,
               training_provider: original_provider,
               accredited_provider: partner_provider)
      end

      it "creates partnership in target cycle" do
        expect {
          service.execute(
            provider: original_provider,
            rolled_over_provider: rolled_over_provider,
            new_recruitment_cycle: target_cycle,
          )
        }.to change(ProviderPartnership, :count).by(1)

        new_partnership = ProviderPartnership.last
        expect(new_partnership.training_provider).to eq(rolled_over_provider)
        expect(new_partnership.accredited_provider).to eq(target_partner)
      end

      it "returns correct count" do
        result = service.execute(
          provider: original_provider,
          rolled_over_provider: rolled_over_provider,
          new_recruitment_cycle: target_cycle,
        )
        expect(result).to eq(1)
      end
    end

    context "when partnership involves rolled-over provider as accredited provider" do
      let(:original_provider) { create(:provider, :accredited_provider, recruitment_cycle: previous_cycle, provider_code: "Accr") }
      let(:rolled_over_provider) { create(:provider, :accredited_provider, recruitment_cycle: target_cycle, provider_code: "Accr") }
      let!(:partner_provider) { create(:provider, recruitment_cycle: previous_cycle, provider_code: "Train") }
      let!(:target_partner) { create(:provider, recruitment_cycle: target_cycle, provider_code: "Train") }
      let!(:partnership) do
        create(:provider_partnership,
               training_provider: partner_provider,
               accredited_provider: original_provider)
      end

      it "creates partnership in target cycle" do
        expect {
          service.execute(
            provider: original_provider,
            rolled_over_provider: rolled_over_provider,
            new_recruitment_cycle: target_cycle,
          )
        }.to change(ProviderPartnership, :count).by(1)

        new_partnership = ProviderPartnership.last
        expect(new_partnership.training_provider).to eq(target_partner)
        expect(new_partnership.accredited_provider).to eq(rolled_over_provider)
      end
    end

    context "when partnership doesn't involve rolled-over provider" do
      let!(:other_provider_one) { create(:provider, recruitment_cycle: previous_cycle, provider_code: "OTH1") }
      let!(:other_provider_two) { create(:provider, :accredited_provider, recruitment_cycle: previous_cycle, provider_code: "OTH2") }
      let!(:partnership) do
        create(:provider_partnership,
               training_provider: other_provider_one,
               accredited_provider: other_provider_two)
      end

      it "does not create partnership" do
        expect {
          service.execute(
            provider: original_provider,
            rolled_over_provider: rolled_over_provider,
            new_recruitment_cycle: target_cycle,
          )
        }.not_to change(ProviderPartnership, :count)
      end
    end

    context "when partner provider doesn't exist in target cycle" do
      let!(:partner_provider) { create(:provider, :accredited_provider, recruitment_cycle: previous_cycle, provider_code: "MISS") }
      let!(:partnership) do
        create(:provider_partnership,
               training_provider: original_provider,
               accredited_provider: partner_provider)
      end

      it "does not create partnership" do
        expect {
          service.execute(
            provider: original_provider,
            rolled_over_provider: rolled_over_provider,
            new_recruitment_cycle: target_cycle,
          )
        }.not_to change(ProviderPartnership, :count)
      end
    end

    context "when partnership already exists in target cycle" do
      let!(:partner_provider) { create(:provider, :accredited_provider, recruitment_cycle: previous_cycle, provider_code: "PART") }
      let!(:target_partner) { create(:provider, :accredited_provider, recruitment_cycle: target_cycle, provider_code: "PART") }
      let!(:existing_partnership) do
        create(:provider_partnership,
               training_provider: rolled_over_provider,
               accredited_provider: target_partner)
      end

      let!(:partnership) do
        create(:provider_partnership,
               training_provider: original_provider,
               accredited_provider: partner_provider)
      end

      it "does not create duplicate partnership" do
        expect {
          service.execute(
            provider: original_provider,
            rolled_over_provider: rolled_over_provider,
            new_recruitment_cycle: target_cycle,
          )
        }.not_to change(ProviderPartnership, :count)
      end
    end
  end
end
