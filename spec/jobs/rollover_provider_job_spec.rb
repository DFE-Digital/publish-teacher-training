# frozen_string_literal: true

require "rails_helper"

RSpec.describe RolloverProviderJob do
  describe "#perform" do
    let(:provider_code) { "ABC123" }

    it "calls the rollover service with correct parameters" do
      expect(RolloverProviderService).to receive(:call).with(provider_code:, force: false)

      subject.perform(provider_code)
    end
  end
end
