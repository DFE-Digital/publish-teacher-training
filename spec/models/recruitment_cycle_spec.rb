# frozen_string_literal: true

require 'rails_helper'

describe RecruitmentCycle do
  subject { current_cycle }

  before { allow(Settings).to receive(:current_recruitment_cycle_year).and_return(2023) }

  let(:current_cycle) { find_or_create(:recruitment_cycle) }
  let(:next_cycle) { find_or_create(:recruitment_cycle, :next) }

  its(:to_s) { is_expected.to eq('2023/24') }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it { is_expected.to validate_presence_of(:year) }

  describe 'associations' do
    describe 'providers' do
      it { is_expected.to have_many(:courses).through(:providers) }

      context 'with discarded providers' do
        let(:provider)           { create(:provider, recruitment_cycle: subject) }
        let(:discarded_provider) { create(:provider, :discarded, recruitment_cycle: subject) }

        it 'does not include the discarded providers' do
          provider
          discarded_provider

          expect(subject.providers).to include(provider)
          expect(subject.providers).not_to include(discarded_provider)
        end
      end
    end

    it { is_expected.to have_many(:sites).through(:providers) }
  end

  describe 'current?' do
    it "returns true when it's the current cycle" do
      expect(current_cycle.current?).to be(true)
    end

    it "returns true false it's not the current cycle" do
      expect(next_cycle.current?).to be(false)
    end
  end

  describe '#after_2024?', :aggregate_failures do
    context 'when cycle year is 2024' do
      before { allow(Settings).to receive(:current_recruitment_cycle_year).and_return(2024) }

      it 'returns false' do
        expect(current_cycle).not_to be_after_2024
        expect(next_cycle).to be_after_2024
      end
    end

    context 'when cycle year is 2025' do
      before { allow(Settings).to receive(:current_recruitment_cycle_year).and_return(2025) }

      it 'returns true' do
        expect(current_cycle).to be_after_2024
        expect(next_cycle).to be_after_2024
      end
    end
  end

  context 'when there are multiple cycles' do
    let!(:third_cycle) do
      current_cycle
      find_or_create :recruitment_cycle, year: next_cycle.year.to_i + 1
    end

    describe '.current_recruitment_cycle' do
      it 'returns the first cycle, ordered by year' do
        expect(described_class.current_recruitment_cycle).to eq(current_cycle)
      end
    end

    describe '#previous' do
      it 'return previous cycle' do
        expect(next_cycle.previous).to eq(current_cycle)
      end

      it 'is nil for the previous cycle' do
        expect(current_cycle.previous).to be_nil
      end
    end

    describe '.next_recruitment_cycle' do
      it 'returns the next cycle after the current one' do
        expect(described_class.next_recruitment_cycle).to eq(next_cycle)
      end
    end

    describe '#next' do
      subject { current_cycle }

      its(:next) { is_expected.to eq(next_cycle) }

      it 'is nil for the newest cycle' do
        expect(third_cycle.next).to be_nil
      end

      it 'returns the next cycle along when there is one' do
        expect(next_cycle.next).to eq(third_cycle)
      end
    end

    describe 'next?' do
      it "returns true when it's the next cycle" do
        expect(next_cycle.next?).to be(true)
      end

      it "returns true false it's not the next cycle" do
        expect(current_cycle.next?).to be(false)
      end
    end
  end
end
