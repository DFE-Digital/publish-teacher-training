# frozen_string_literal: true

require "rails_helper"

describe ProviderURNIdentificationService do
  subject { described_class.new(provider, urns).call }

  let(:provider) { create(:provider) }
  let(:new_urns) { create_list(:gias_school, 3).pluck(:urn) }

  describe "all urns are new" do
    let(:urns) { new_urns }

    it "returns correct hash" do
      expect(subject[:unfound_urns]).to be_blank
      expect(subject[:duplicate_urns]).to be_blank
      expect(subject[:new_urns]).to eq(new_urns)
    end
  end

  describe "one urn is unfound" do
    let(:new_urns) { create_list(:gias_school, 2).pluck(:urn) }
    let(:urns) { new_urns + %w[unfound] }

    it "returns correct hash" do
      expect(subject[:unfound_urns]).to eq(%w[unfound])
      expect(subject[:duplicate_urns]).to be_blank
      expect(subject[:new_urns]).to eq(new_urns)
    end
  end

  describe "one urn is duplicate" do
    let(:new_urns) { create_list(:gias_school, 2).pluck(:urn) }
    let(:existing_school) { create(:gias_school) }
    let(:urns) { new_urns + %w[unfound] + [existing_school.urn] }

    it "returns correct hash" do
      provider.sites.create!(existing_school.school_attributes)

      expect(subject[:unfound_urns]).to eq(%w[unfound])
      expect(subject[:duplicate_urns]).to eq([existing_school.urn])
      expect(subject[:new_urns]).to eq(new_urns)
    end
  end
end
