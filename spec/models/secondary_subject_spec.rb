# frozen_string_literal: true

require 'rails_helper'

describe SecondarySubject do
  describe '#modern_languages' do
    let!(:modern_languages) do
      find_or_create(:secondary_subject, :modern_languages)
    end

    it 'returns the modern language subject' do
      expect(described_class.modern_languages).to eq(modern_languages)
    end

    it 'memoises the subject object' do
      described_class.modern_languages

      allow(described_class).to receive(:find_by)

      expect(described_class.modern_languages).to eq(modern_languages)
      expect(described_class).not_to have_received(:find_by)
    end
  end

  describe '#physics' do
    let!(:physics) do
      find_or_create(:secondary_subject, :physics)
    end

    it 'returns the physics subject' do
      expect(described_class.physics).to eq(physics)
    end

    it 'memoises the subject object' do
      described_class.physics

      allow(described_class).to receive(:find_by)

      expect(described_class.physics).to eq(physics)
      expect(described_class).not_to have_received(:find_by)
    end
  end
end
