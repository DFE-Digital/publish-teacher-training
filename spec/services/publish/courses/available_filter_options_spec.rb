# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Courses::AvailableFilterOptions do
  subject(:months) { described_class.for(Publish::CourseList.new(provider:).unfiltered_courses).fetch(:start_date) }

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

  describe "the other groups" do
    subject(:options) { described_class.for(Publish::CourseList.new(provider:).unfiltered_courses) }

    it "compacts nil values" do
      create(:course, :primary, :fee, :resulting_in_qts, provider:, study_mode: :full_time)
      row = Publish::CourseList.new(provider:).unfiltered_courses.sole
      allow(row).to receive_messages(level: nil, funding: nil, qualification: nil, study_mode: nil, start_date: nil)

      options = described_class.for([row])

      expect(options[:level]).to eq([])
      expect(options[:funding]).to eq([])
      expect(options[:qualification]).to eq([])
      expect(options[:study_mode]).to eq([])
      expect(options[:start_date]).to eq([])
      expect(options[:status]).to eq(%w[draft])
    end

    it "offers each value once" do
      create_list(:course, 2, :primary, :fee, :resulting_in_qts, provider:, study_mode: :full_time)

      expect(options[:status]).to eq(%w[draft])
      expect(options[:level]).to eq(%w[primary])
      expect(options[:funding]).to eq(%w[fee])
      expect(options[:qualification]).to eq(%w[qts])
      expect(options[:study_mode]).to eq(%w[full_time])
    end

    it "ignores discarded courses" do
      create(:course, :secondary, :salary, :deleted, provider:)

      expect(options[:status]).to be_empty
      expect(options[:level]).to be_empty
      expect(options[:funding]).to be_empty
    end
  end

  describe "the scheduled token" do
    def statuses_for(cycle_provider)
      described_class.for(Publish::CourseList.new(provider: cycle_provider).unfiltered_courses).fetch(:status)
    end

    it "is open in the current cycle" do
      current_provider = create(:provider)
      create(:course, :published, provider: current_provider, application_status: :open)

      expect(statuses_for(current_provider)).to eq(%w[open])
    end

    it "is open in the previous cycle" do
      previous_provider = create(:provider, :previous_recruitment_cycle)
      create(:course, :published, provider: previous_provider, application_status: :open)

      expect(statuses_for(previous_provider)).to eq(%w[open])
    end

    it "is scheduled in a future cycle" do
      next_provider = create(:provider, :next_recruitment_cycle)
      create(:course, :published, provider: next_provider, application_status: :closed)

      expect(statuses_for(next_provider)).to eq(%w[scheduled])
    end
  end
end
