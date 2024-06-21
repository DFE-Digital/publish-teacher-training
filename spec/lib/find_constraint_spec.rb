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

  context 'when request host start with find' do
    let(:host) { 'find-teacher-training' }

    it 'returns true' do
      expect(subject).to be true
    end
  end

  context 'when request host is in other environments' do
    let(:host) { 'qa.find-teacher-training' }

    it 'returns true' do
      expect(subject).to be true
    end
  end

  context 'when request host does not start with find' do
    let(:host) { 'publish-teacher-training' }

    it 'returns false' do
      expect(subject).to be false
    end
  end
end
