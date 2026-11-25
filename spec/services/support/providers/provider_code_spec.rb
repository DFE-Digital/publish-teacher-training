# frozen_string_literal: true

require "rails_helper"

RSpec.describe Support::Providers::ProviderCode do
  let(:recruitment_cycle) { find_or_create(:recruitment_cycle) }

  describe ".call" do
    it "returns a provider code that is valid and unused in the recruitment cycle" do
      code = described_class.call(recruitment_cycle:)

      expect(code).to match(Support::ProviderForm::PROVIDER_CODE_FORMAT)
      expect(Provider.with_discarded.exists?(recruitment_cycle:, provider_code: code)).to be(false)
    end

    it "does not return a code already used in the same recruitment cycle" do
      create(:provider, recruitment_cycle:, provider_code: "Z99")

      expect(described_class.call(recruitment_cycle:)).not_to eq("Z99")
    end

    it "loads the used codes in one query" do
      create(:provider, recruitment_cycle:, provider_code: "Z99")

      expect(count_queries { described_class.call(recruitment_cycle:) }).to eq(1)
    end

    it "returns nil when every valid code is already used" do
      create(:provider, recruitment_cycle:, provider_code: "Z99")
      service = described_class.send(:new, recruitment_cycle:)
      allow(service).to receive(:valid_codes).and_return(%w[Z99])

      expect(service.call).to be_nil
    end
  end
end
