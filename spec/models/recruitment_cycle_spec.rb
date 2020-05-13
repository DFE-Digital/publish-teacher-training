# == Schema Information
#
# Table name: recruitment_cycle
#
#  id                     :bigint           not null, primary key
#  year                   :string
#  application_start_date :date             not null
#  application_end_date   :date             not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

require "rails_helper"

describe RecruitmentCycle, type: :model do
  let(:current_cycle) { find_or_create(:recruitment_cycle) }
  let(:next_cycle) { find_or_create(:recruitment_cycle, :next) }

  subject { current_cycle }

  its(:to_s) { should eq("2020/21") }

  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end

  it { is_expected.to validate_presence_of(:year) }

  describe "associations" do
    describe "providers" do
      it { should have_many(:courses).through(:providers) }

      context "with discarded providers" do
        let(:provider)           { create :provider, recruitment_cycle: subject }
        let(:discarded_provider) { create :provider, :discarded, recruitment_cycle: subject }

        it "does not include the discarded providers" do
          provider
          discarded_provider

          expect(subject.providers).to include(provider)
          expect(subject.providers).not_to include(discarded_provider)
        end
      end
    end
    it { should have_many(:sites).through(:providers) }
  end

  describe "current?" do
    it "should return true when it's the current cycle" do
      expect(current_cycle.current?).to be(true)
    end

    it "should return true false it's not the current cycle" do
      expect(next_cycle.current?).to be(false)
    end
  end

  context "when there are multiple cycles" do
    let!(:third_cycle) do
      find_or_create :recruitment_cycle, year: next_cycle.year.to_i + 1
    end

    describe ".current_recruitment_cycle" do
      it "returns the first cycle, ordered by year" do
        expect(RecruitmentCycle.current_recruitment_cycle).to eq(current_cycle)
      end
    end

    describe "#previous" do
      it "return previous cycle" do
        expect(next_cycle.previous).to eq(current_cycle)
      end

      it "is nil for the previous cycle" do
        expect(current_cycle.previous).to be_nil
      end
    end

    describe ".next_recruitment_cycle" do
      it "returns the next cycle after the current one" do
        expect(RecruitmentCycle.next_recruitment_cycle).to eq(next_cycle)
      end
    end

    describe "#next" do
      subject { current_cycle }
      its(:next) { should eq(next_cycle) }

      it "is nil for the newest cycle" do
        expect(third_cycle.next).to be_nil
      end

      it "returns the next cycle along when there is one" do
        expect(next_cycle.next).to eq(third_cycle)
      end
    end

    describe "next?" do
      it "should return true when it's the next cycle" do
        expect(next_cycle.next?).to be(true)
      end

      it "should return true false it's not the next cycle" do
        expect(current_cycle.next?).to be(false)
      end
    end
  end
end
