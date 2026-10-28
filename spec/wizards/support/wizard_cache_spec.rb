# frozen_string_literal: true

require "rails_helper"

RSpec.describe Support::WizardCache do
  describe ".store" do
    it "uses Rails.cache when that store keeps values" do
      expect(described_class.store).to eq(Rails.cache)
    end

    it "uses a memory store when Rails.cache discards writes" do
      null_store = ActiveSupport::Cache::NullStore.new
      allow(Rails).to receive(:cache).and_return(null_store)
      described_class.instance_variable_set(:@store, nil)

      store = described_class.store
      store.write("support_wizard", "kept")

      expect(store.read("support_wizard")).to eq("kept")
      expect(null_store.read("support_wizard")).to be_nil
    ensure
      described_class.instance_variable_set(:@store, nil)
    end
  end
end
