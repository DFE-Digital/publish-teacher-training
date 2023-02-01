# frozen_string_literal: true

require 'rails_helper'

describe Find::ProviderHelper do
  describe '#select_provider_options' do
    subject { select_provider_options(providers) }

    let(:providers) { build_list(:provider, 3) }

    it 'returns select provider options ids' do
      expect(subject.map(&:id)).to eql([''] + providers.map(&:provider_name))
    end

    it 'returns select provider options names' do
      expect(subject.map(&:name)).to eql(['Select a provider'] + providers.map { |p| "#{p.provider_name} (#{p.provider_code})" })
    end
  end
end
