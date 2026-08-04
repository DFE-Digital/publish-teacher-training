# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Courses::AvailableStartMonths do
  subject(:months) { described_class.for(provider) }

  let(:provider) { create(:provider) }

  it "is empty when the provider has no courses" do
    expect(months).to be_empty
  end

  it "offers the month each course starts in" do
    create(:course, provider:, start_date: Time.zone.local(2026, 9, 1))

    expect(months).to eq([Date.new(2026, 9, 1)])
  end

  it "orders them earliest first" do
    create(:course, provider:, start_date: Time.zone.local(2027, 1, 1))
    create(:course, provider:, start_date: Time.zone.local(2026, 9, 1))

    expect(months).to eq([Date.new(2026, 9, 1), Date.new(2027, 1, 1)])
  end

  it "offers a month once, however many courses start in it" do
    create(:course, provider:, start_date: Time.zone.local(2026, 9, 1))
    create(:course, provider:, start_date: Time.zone.local(2026, 9, 20))

    expect(months).to eq([Date.new(2026, 9, 1)])
  end

  it "offers a month outside the cycle window when a course starts then" do
    create(:course, :without_validation, provider:, start_date: Time.zone.local(2030, 3, 1))

    expect(months).to eq([Date.new(2030, 3, 1)])
  end

  it "ignores courses with no start date" do
    create(:course, :without_validation, provider:, start_date: nil)
    create(:course, provider:, start_date: Time.zone.local(2026, 9, 1))

    expect(months).to eq([Date.new(2026, 9, 1)])
  end

  it "ignores another provider's courses" do
    create(:course, start_date: Time.zone.local(2027, 1, 1))

    expect(months).to be_empty
  end

  it "ignores deleted courses" do
    create(:course, :deleted, provider:, start_date: Time.zone.local(2026, 9, 1))

    expect(months).to be_empty
  end

  # Stored as 2026-08-31 23:30 UTC, but the list displays it — and the provider
  # thinks of it — as September, which is also the month Query matches it under.
  it "offers the month a course displays under, not the UTC one" do
    course = create(:course, provider:, start_date: Time.zone.local(2026, 9, 1, 0, 30))

    expect(course.start_date.utc.day).to eq(31)
    expect(months).to eq([Date.new(2026, 9, 1)])
  end

  # The checkbox label comes from I18n.l(month, format: :short), which resolves
  # "%B %Y" for a Date and a quite different default for a Time.
  it "returns dates" do
    create(:course, provider:, start_date: Time.zone.local(2026, 9, 1))

    expect(months).to all(be_an_instance_of(Date))
  end
end
