# frozen_string_literal: true

require 'rails_helper'

describe FeatureFlag do
  describe '.active?' do
    before do
      allow(FeatureFlags).to receive(:all).and_return([[:test_feature, "It's a test feature", 'Jasmine Java']])
    end

    it 'returns false if the feature flag has been deactivated' do
      described_class.deactivate('test_feature')

      expect(described_class.active?('test_feature')).to be(false)
    end

    it 'returns true if the feature flag has been activated' do
      described_class.activate('test_feature')

      expect(described_class.active?('test_feature')).to be(true)
    end

    it 'returns false if the feature does not exist' do
      expect(described_class.active?('test_feature')).to be(false)
    end
  end

  describe '.deactivate' do
    before do
      allow(FeatureFlags).to receive(:all).and_return([[:test_feature, "It's a test feature", 'Jasmine Java']])
    end

    it 'deactivates the feature flag' do
      described_class.deactivate('test_feature')

      expect(described_class.active?('test_feature')).to be(false)
    end
  end

  describe '.activate' do
    before do
      allow(FeatureFlags).to receive(:all).and_return([[:test_feature, "It's a test feature", 'Jasmine Java']])
    end

    it 'activates the feature flag' do
      described_class.activate('test_feature')

      expect(described_class.active?('test_feature')).to be(true)
    end
  end
end
