# frozen_string_literal: true

require "rails_helper"

describe Subject do
  subject { find_or_create(:modern_languages_subject, subject_name: "Modern languages (other)", subject_code: "101") }

  it { is_expected.to have_many(:courses).through(:course_subjects) }
  its(:to_sym) { is_expected.to eq(:modern_languages_other) }
  its(:to_s) { is_expected.to eq("Modern languages (other)") }

  it "can get a financial incentive" do
    financial_incentive = create(:financial_incentive, subject:)
    expect(subject.financial_incentive).to eq(financial_incentive)
  end

  it "returns all active subjects" do
    expect(described_class.active.pluck(:type)).not_to include("DiscontinuedSubject")
  end

  it "returns all primary subjects" do
    expect(described_class.primary.pluck(:type)).to include("PrimarySubject")
  end

  it "returns all secondary subjects" do
    expect(described_class.secondary.pluck(:type)).to include("SecondarySubject")
    expect(described_class.secondary.pluck(:type)).to include("ModernLanguagesSubject")
    expect(described_class.secondary.pluck(:type)).not_to include("Modern Languages")
  end

  context "when returning subject codes" do
    before do
      FinancialIncentive.delete_all
      described_class.delete_all

      find_or_create(:primary_subject, :primary_with_english, subject_code: "00")
      find_or_create(:primary_subject, :primary, subject_code: "01")

      find_or_create(:modern_languages_subject, subject_name: "Modern languages (other)", subject_code: "101")
      find_or_create(:secondary_subject, :ancient_greek, subject_code: "102")
    end

    it "returns all primary_subject_codes" do
      expect(described_class.primary_subject_codes).to match_array(%w[00 01])
    end

    it "returns all secondary_subject_codes_with_incentives" do
      expect(described_class.secondary_subject_codes_with_incentives).to match_array(%w[101 102])
    end
  end

  describe '#match_synonyms_text' do
    context 'when match_synonyms is nil' do
      subject { build(:secondary_subject, :mathematics, match_synonyms: nil) }

      it 'returns an empty string' do
        expect(subject.match_synonyms_text).to eq("")
      end
    end

    context 'when match_synonyms is an empty array' do
      subject { build(:secondary_subject, :mathematics, match_synonyms: []) }

      it 'returns an empty string' do
        expect(subject.match_synonyms_text).to eq("")
      end
    end

    context 'when match_synonyms contains a single synonym' do
      subject { build(:secondary_subject, :mathematics, match_synonyms: ['Mathematics']) }

      it 'returns the synonym without newlines' do
        expect(subject.match_synonyms_text).to eq("Mathematics")
      end
    end

    context 'when match_synonyms contains multiple synonyms' do
      subject { build(:secondary_subject, :mathematics, match_synonyms: ['Maths', 'Mathematics', 'Math']) }

      it 'returns synonyms separated by newlines' do
        expect(subject.match_synonyms_text).to eq("Maths\nMathematics\nMath")
      end
    end

    context 'when match_synonyms contains synonyms with special characters' do
      subject { build(:secondary_subject, :mathematics, match_synonyms: ['Physical Education', 'P.E.', 'PE & Sport']) }

      it 'preserves special characters and spacing' do
        expect(subject.match_synonyms_text).to eq("Physical Education\nP.E.\nPE & Sport")
      end
    end

    context 'when match_synonyms contains empty strings (edge case)' do
      subject { build(:secondary_subject, :mathematics, match_synonyms: ['', 'Maths', '']) }

      it 'includes empty strings as newlines' do
        expect(subject.match_synonyms_text).to eq("Maths")
      end
    end
  end
end
