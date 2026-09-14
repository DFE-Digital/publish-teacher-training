# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::CycleStartMonths do
  # The window is January of the cycle year to July of the next, so the month
  # names below are part of the rule under test. The year is not: nothing here
  # behaves differently from one cycle to the next, so it stays relative and the
  # spec keeps testing whichever cycle is current.
  let(:year) { Find::CycleTimetable.current_year }

  describe ".for" do
    subject(:months) { described_class.for(year) }

    it "covers the whole cycle year and the first seven months of the next" do
      expect(months.size).to eq(19)
    end

    it "starts at January of the cycle year" do
      expect(months.first).to eq(Date.new(year, 1, 1))
    end

    it "ends at July of the following year" do
      expect(months.last).to eq(Date.new(year + 1, 7, 1))
    end

    it "returns the first of each consecutive month" do
      expect(months).to eq((0..18).map { |offset| Date.new(year, 1, 1) + offset.months })
    end

    it "accepts the year as a string" do
      expect(described_class.for(year.to_s)).to eq(months)
    end
  end

  describe ".labels_for" do
    subject(:labels) { described_class.labels_for(year) }

    it "labels each month with its name and year" do
      expect(labels.first).to eq("January #{year}")
      expect(labels.last).to eq("July #{year + 1}")
    end

    it "has a label for every month" do
      expect(labels.size).to eq(described_class.for(year).size)
    end
  end

  describe ".remaining_labels_for" do
    it "offers every month when the cycle has not started" do
      labels = described_class.remaining_labels_for(year, Date.new(year - 1, 10, 1))

      expect(labels).to eq(described_class.labels_for(year))
    end

    it "offers every month on the first day of the cycle's first month" do
      labels = described_class.remaining_labels_for(year, Date.new(year, 1, 1))

      expect(labels).to eq(described_class.labels_for(year))
    end

    it "drops the months that have ended" do
      labels = described_class.remaining_labels_for(year, Date.new(year, 6, 10))

      expect(labels.first).to eq("June #{year}")
      expect(labels).not_to include("May #{year}")
    end

    it "keeps the current month until it ends" do
      labels = described_class.remaining_labels_for(year, Date.new(year, 6, 30))

      expect(labels.first).to eq("June #{year}")
    end

    it "drops past months once the cycle has been superseded" do
      labels = described_class.remaining_labels_for(year, Date.new(year + 1, 2, 1))

      expect(labels).to eq(
        (2..7).map { |month| "#{Date::MONTHNAMES[month]} #{year + 1}" },
      )
    end

    it "offers only the last month while that month is still running" do
      labels = described_class.remaining_labels_for(year, Date.new(year + 1, 7, 31))

      expect(labels).to eq(["July #{year + 1}"])
    end

    it "falls back on the first day after the last month" do
      labels = described_class.remaining_labels_for(year, Date.new(year + 1, 8, 1))

      expect(labels).to eq(described_class.labels_for(year))
    end

    it "offers the whole cycle once every month has long passed" do
      labels = described_class.remaining_labels_for(year, Date.new(year + 2, 1, 1))

      expect(labels).to eq(described_class.labels_for(year))
    end

    it "accepts the year as a string" do
      today = Date.new(year, 6, 10)

      expect(described_class.remaining_labels_for(year.to_s, today))
        .to eq(described_class.remaining_labels_for(year, today))
    end

    it "defaults to today", travel: first_deadline_banner do
      # first_deadline_banner is 12 July of the cycle year, so July is the first
      # month of that cycle still available.
      expect(described_class.remaining_labels_for(year).first).to eq("July #{year}")
    end
  end

  describe ".label_for" do
    it "names the month and its year" do
      expect(described_class.label_for(Date.new(year, 3, 1))).to eq("March #{year}")
    end
  end
end
