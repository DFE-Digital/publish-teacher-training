# frozen_string_literal: true

require "rails_helper"

describe SecondarySubject do
  describe "#modern_languages" do
    let!(:modern_languages) do
      find_or_create(:secondary_subject, :modern_languages)
    end

    it "returns the modern language subject" do
      expect(SecondarySubject.modern_languages).to eq(modern_languages)
    end

    it "memoises the subject object" do
      SecondarySubject.modern_languages

      allow(SecondarySubject).to receive(:find_by)

      expect(SecondarySubject.modern_languages).to eq(modern_languages)
      expect(SecondarySubject).not_to have_received(:find_by)
    end
  end

  describe "#physics" do
    let!(:physics) do
      find_or_create(:secondary_subject, :physics)
    end

    it "returns the physics subject" do
      expect(SecondarySubject.physics).to eq(physics)
    end

    it "memoises the subject object" do
      SecondarySubject.physics

      allow(SecondarySubject).to receive(:find_by)

      expect(SecondarySubject.physics).to eq(physics)
      expect(SecondarySubject).not_to have_received(:find_by)
    end
  end
end
