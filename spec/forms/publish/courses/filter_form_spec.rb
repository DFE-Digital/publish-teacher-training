# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Courses::FilterForm do
  subject(:form) { described_class.new(provider:, **attributes) }

  let(:provider) { create(:provider) }
  let(:cycle_year) { provider.recruitment_cycle.year.to_i }
  let(:attributes) { {} }

  describe "allowed values" do
    context "when every value is recognised" do
      let(:attributes) { { status: %w[open draft], level: %w[primary] } }

      it "keeps them" do
        expect(form.status).to eq(%w[open draft])
        expect(form.level).to eq(%w[primary])
      end
    end

    context "when a value is not recognised" do
      let(:attributes) { { status: %w[open bogus], funding: %w[bogus] } }

      it "drops it from the group" do
        expect(form.status).to eq(%w[open])
        expect(form.funding).to be_empty
      end

      it "keeps it out of the query params" do
        expect(form.filter_params).to eq(status: %w[open])
      end

      it "keeps it out of the counts" do
        expect(form.filter_counts[:funding]).to be_nil
      end

      it "keeps it out of the active filters" do
        expect(form.active_filters.map(&:raw_value)).to eq(%w[open])
      end
    end

    context "when a single value arrives as a string rather than an array" do
      let(:attributes) { { level: "secondary" } }

      it "wraps it" do
        expect(form.level).to eq(%w[secondary])
      end
    end

    context "when a start date month is not in the cycle window" do
      let(:attributes) { { start_date: ["#{cycle_year + 5}-09", "#{cycle_year}-09"] } }

      it "drops it" do
        expect(form.start_date).to eq(["#{cycle_year}-09"])
      end
    end
  end

  describe "#filter_params" do
    context "when nothing is selected" do
      it "is empty" do
        expect(form.filter_params).to be_empty
      end
    end

    context "when several groups are selected" do
      let(:attributes) { { status: %w[open], study_mode: %w[part_time] } }

      it "includes only the groups with a selection" do
        expect(form.filter_params).to eq(status: %w[open], study_mode: %w[part_time])
      end
    end
  end

  describe "#filter_counts" do
    let(:attributes) { { status: %w[open closed], level: %w[primary] } }

    it "counts the selections in each group" do
      expect(form.filter_counts[:status]).to eq(2)
      expect(form.filter_counts[:level]).to eq(1)
    end

    it "is nil for a group with no selection" do
      expect(form.filter_counts[:funding]).to be_nil
    end

    it "has an entry for every group" do
      expect(form.filter_counts.keys).to eq(described_class::GROUPS)
    end
  end

  describe "#any_filters?" do
    it "is false when nothing is selected" do
      expect(form.any_filters?).to be(false)
    end

    context "when something is selected" do
      let(:attributes) { { level: %w[primary] } }

      it "is true" do
        expect(form.any_filters?).to be(true)
      end
    end

    context "when only an unrecognised value is given" do
      let(:attributes) { { level: %w[bogus] } }

      it "is false" do
        expect(form.any_filters?).to be(false)
      end
    end
  end

  describe "#options_for" do
    it "labels the statuses as the provider sees them on the list" do
      expect(form.options_for(:status).map(&:label))
        .to eq(["Open", "Closed", "Draft", "Rolled over", "Scheduled", "Withdrawn"])
    end

    it "labels the education phases" do
      expect(form.options_for(:level).map(&:label)).to eq(["Primary", "Secondary", "Further education"])
    end

    it "labels the funding types" do
      expect(form.options_for(:funding).map(&:label)).to eq(%w[Fee-paying Salary Apprenticeship])
    end

    it "labels the qualifications" do
      expect(form.options_for(:qualification).map(&:label)).to eq(["QTS only", "QTS with PGCE or PGDE"])
    end

    it "labels the study modes" do
      expect(form.options_for(:study_mode).map(&:label)).to eq(["Full time", "Part time"])
    end
  end

  describe "start date options" do
    subject(:options) { form.options_for(:start_date) }

    it "covers the whole cycle window" do
      expect(options.size).to eq(19)
    end

    it "starts in January of the cycle year" do
      expect(options.first).to have_attributes(value: "#{cycle_year}-01", label: "January #{cycle_year}")
    end

    it "ends in July of the following year" do
      expect(options.last).to have_attributes(value: "#{cycle_year + 1}-07", label: "July #{cycle_year + 1}")
    end

    it "does not drop months that have already passed" do
      travel_to(Time.zone.local(cycle_year, 6, 15)) do
        expect(described_class.new(provider:).options_for(:start_date).first.label).to eq("January #{cycle_year}")
      end
    end
  end

  describe "#active_filters" do
    let(:attributes) { { study_mode: %w[part_time], status: %w[open closed] } }

    it "orders them by filter group, then by selection" do
      expect(form.active_filters.map(&:formatted_value)).to eq(["Open", "Closed", "Part time"])
    end

    it "identifies each one by its group" do
      expect(form.active_filters.map(&:id)).to eq(%i[status status study_mode])
    end

    it "removes only the chosen value from its group" do
      open_filter = form.active_filters.first

      expect(open_filter.remove_params).to eq(status: %w[closed])
    end

    it "clears the group when its last value is removed" do
      part_time = form.active_filters.last

      expect(part_time.remove_params).to eq(study_mode: nil)
    end

    context "with a start date selected" do
      let(:attributes) { { start_date: ["#{cycle_year}-09"] } }

      it "labels the chip with the month" do
        expect(form.active_filters.map(&:formatted_value)).to eq(["September #{cycle_year}"])
      end
    end

    context "when nothing is selected" do
      let(:attributes) { {} }

      it "is empty" do
        expect(form.active_filters).to be_empty
      end
    end
  end
end
