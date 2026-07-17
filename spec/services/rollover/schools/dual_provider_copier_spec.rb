# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rollover::Schools::DualProviderCopier do
  subject(:copier) { described_class.new(legacy_copier:, new_copier:) }

  let(:legacy_copier) { instance_double(Rollover::Schools::LegacyProviderCopier) }
  let(:new_copier) { instance_double(Rollover::Schools::NewProviderCopier) }
  let(:provider) { build_stubbed(:provider) }
  let(:new_provider) { build_stubbed(:provider) }
  let(:legacy_result) { { copied: 2, skipped: [] } }

  it "copies both legacy sites and new provider-school relationships" do
    allow(legacy_copier).to receive(:execute).and_return(legacy_result)
    allow(new_copier).to receive(:execute)

    copier.execute(provider:, new_provider:)

    expect(legacy_copier).to have_received(:execute).with(provider:, new_provider:)
    expect(new_copier).to have_received(:execute).with(provider:, new_provider:)
  end

  it "returns the legacy result used by rollover reporting" do
    allow(legacy_copier).to receive(:execute).and_return(legacy_result)
    allow(new_copier).to receive(:execute)

    expect(copier.execute(provider:, new_provider:)).to eq(legacy_result)
  end
end
