# frozen_string_literal: true

require "rails_helper"

RSpec.describe Find::PreviousCycleCourse do
  describe ".visible?" do
    subject { described_class.visible?(course) }

    let(:previous_cycle) { find_or_create(:recruitment_cycle, year: 2026) }
    let(:provider) { create(:provider, recruitment_cycle: previous_cycle) }
    let(:start_date) { Time.zone.local(previous_cycle.year.to_i, 10, 1) }
    let(:course) { create(:course, :published, provider:, start_date:) }

    context "when the previous cycle is 2026", travel: find_opens(2027) + 1.day do
      it { is_expected.to be(true) }
    end

    context "when the course start date has passed", travel: Time.zone.local(2026, 10, 2) do
      it { is_expected.to be(false) }
    end

    context "when the course starts on or before 30 September", travel: find_opens(2027) + 1.hour do
      let(:start_date) { Time.zone.local(previous_cycle.year.to_i, 9, 30) }

      it { is_expected.to be(false) }
    end

    context "when the previous cycle is 2025", travel: find_opens(2026) + 1.day do
      let(:previous_cycle) { find_or_create(:recruitment_cycle, year: 2025) }
      let(:start_date) { Time.zone.local(2025, 11, 1) }

      it { is_expected.to be(false) }
    end

    context "when the course is in the current cycle", travel: find_opens(2027) + 1.day do
      let(:provider) { create(:provider) }
      let(:start_date) { Time.zone.local(2027, 10, 1) }

      it { is_expected.to be(false) }
    end

    context "when the course is not published", travel: find_opens(2027) + 1.day do
      let(:course) { create(:course, provider:, start_date:) }

      it { is_expected.to be(false) }
    end

    it "is not visible without a course" do
      expect(described_class.visible?(nil)).to be(false)
    end
  end

  describe ".current_cycle_equivalent", travel: find_opens(2027) + 1.day do
    let(:previous_cycle) { find_or_create(:recruitment_cycle, year: 2026) }
    let(:previous_provider) { create(:provider, recruitment_cycle: previous_cycle, provider_code: "ABC") }
    let(:current_provider) { create(:provider, provider_code: "ABC") }
    let(:course) { create(:course, :published, provider: previous_provider, course_code: "C1", start_date: Time.zone.local(2026, 10, 1)) }

    it "returns the published current-cycle course with the same codes" do
      current_course = create(:course, :published, provider: current_provider, course_code: "C1", name: "Art and design")

      expect(described_class.current_cycle_equivalent(course)).to eq(current_course)
    end

    it "returns nil when there is no matching current-cycle course" do
      expect(described_class.current_cycle_equivalent(course)).to be_nil
    end

    it "returns nil when the current-cycle course is not published" do
      create(:course, provider: current_provider, course_code: "C1")

      expect(described_class.current_cycle_equivalent(course)).to be_nil
    end
  end
end
