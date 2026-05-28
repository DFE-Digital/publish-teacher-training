# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::ActiveFilters::SummaryRowBuilder do
  describe "VALUE_FORMATTERS" do
    subject(:formatter) { described_class::VALUE_FORMATTERS[id] }

    context "with an unknown id (default formatter)" do
      let(:id) { :anything_else }

      it "joins values with a comma" do
        expect(formatter.call(%w[Alpha Beta])).to eq("Alpha, Beta")
      end

      it "returns a single value unchanged" do
        expect(formatter.call(%w[Solo])).to eq("Solo")
      end
    end

    context "with :funding" do
      let(:id) { :funding }

      it "joins values then humanizes (only the first character is capitalised)" do
        expect(formatter.call(%w[fee salary])).to eq("Fee, salary")
      end

      it "replaces underscores with spaces" do
        expect(formatter.call(%w[fee_funded salary])).to eq("Fee funded, salary")
      end
    end

    context "with :study_types" do
      let(:id) { :study_types }

      it "joins values then humanizes" do
        expect(formatter.call(%w[full_time part_time])).to eq("Full time, part time")
      end
    end

    context "with :subjects" do
      let(:id) { :subjects }

      it "returns a single subject capitalised" do
        expect(formatter.call(%w[Mathematics])).to eq("Mathematics")
      end

      it "joins two subjects with 'and'" do
        expect(formatter.call(%w[Physics Mathematics])).to eq("Mathematics and physics")
      end

      it "sorts subjects, lowercasing all but the first" do
        expect(formatter.call(%w[Physics Biology Chemistry])).to eq("Biology, chemistry, physics")
      end

      it "preserves language proper nouns in their original case" do
        expect(formatter.call(%w[Physics French Biology])).to eq("Biology, French, physics")
      end

      it "down-cases the descriptive 'Ancient' but preserves the language proper noun" do
        expect(formatter.call(["Ancient Greek", "Ancient Hebrew", "Mathematics"]))
          .to eq("Ancient Greek, ancient Hebrew, mathematics")
      end
    end
  end
end
