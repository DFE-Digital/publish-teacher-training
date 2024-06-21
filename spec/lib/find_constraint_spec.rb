# frozen_string_literal: true

require 'rails_helper'

describe FindConstraint do
  subject do
    described_class.new.matches?(request)
  end

  let(:request) do
    double(
      :request,
      host:
    )
  end

  let(:find_url) { 'find_url' }
  let(:host) { 'find_url' }
  let(:extra_find_url) { 'some_url' }

  describe '#matched?' do
    before do
      Settings.find_url = find_url
      Settings.extra_find_url = extra_find_url
    end

    context 'Settings.find_url is same as host' do
      it 'returns true' do
        expect(subject).to be_truthy
      end
    end

    context 'when request host matches extra_find_url' do
      let(:host) { 'some_url' }

      it 'returns true' do
        expect(subject).to be_truthy
      end
    end

    context 'Settings.find_url is different to host' do
      let(:host) { 'find_different_url' }

      it 'returns false' do
        expect(subject).to be_falsey
      end
    end

    context 'Review environment' do
      let(:host) { 'find-pr-123' }

      it 'returns true' do
        expect(subject).to be_truthy
      end
    end

    context 'Settings.find_url is nil' do
      let(:find_url) { nil }

      it 'returns false' do
        expect(subject).to be_falsey
      end
    end
  end
end
