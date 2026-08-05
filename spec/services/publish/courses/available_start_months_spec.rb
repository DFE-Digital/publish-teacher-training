# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Courses::AvailableStartMonths do
  subject(:months) { described_class.for(provider) }

  let(:provider) { create(:provider) }
  let(:cycle_year) { provider.recruitment_cycle_year.to_i }
  let(:september) { Date.new(cycle_year, 9, 1) }
  let(:january) { Date.new(cycle_year + 1, 1, 1) }

  it "is empty when the provider has no courses" do
    expect(months).to be_empty
  end

  it "offers the month each course starts in" do
    create(:course, provider:, start_date: september.in_time_zone)

    expect(months).to eq([september])
  end

  it "orders them earliest first" do
    create(:course, provider:, start_date: january.in_time_zone)
    create(:course, provider:, start_date: september.in_time_zone)

    expect(months).to eq([september, january])
  end

  it "offers a month once, however many courses start in it" do
    create(:course, provider:, start_date: september.in_time_zone)
    create(:course, provider:, start_date: Time.zone.local(cycle_year, 9, 20))

    expect(months).to eq([september])
  end

  # The window runs to July of the following year, so this is well outside it.
  it "offers a month outside the cycle window when a course starts then" do
    out_of_window = Date.new(cycle_year + 5, 3, 1)
    create(:course, :without_validation, provider:, start_date: out_of_window.in_time_zone)

    expect(months).to eq([out_of_window])
  end

  it "ignores courses with no start date" do
    create(:course, :without_validation, provider:, start_date: nil)
    create(:course, provider:, start_date: september.in_time_zone)

    expect(months).to eq([september])
  end

  it "ignores another provider's courses" do
    create(:course, start_date: january.in_time_zone)

    expect(months).to be_empty
  end

  it "ignores deleted courses" do
    create(:course, :deleted, provider:, start_date: september.in_time_zone)

    expect(months).to be_empty
  end

  # Stored as 31 August 23:30 UTC, because the 1st of September falls in British
  # Summer Time. The list displays it — and the provider thinks of it — as
  # September, which is also the month Query matches it under.
  it "offers the month a course displays under, not the UTC one" do
    course = create(:course, provider:, start_date: Time.zone.local(cycle_year, 9, 1, 0, 30))

    expect(course.start_date.utc.day).to eq(31)
    expect(months).to eq([september])
  end

  # The checkbox label comes from I18n.l(month, format: :short), which resolves
  # "%B %Y" for a Date and a quite different default for a Time.
  it "returns dates" do
    create(:course, provider:, start_date: september.in_time_zone)

    expect(months).to all(be_an_instance_of(Date))
  end
end
