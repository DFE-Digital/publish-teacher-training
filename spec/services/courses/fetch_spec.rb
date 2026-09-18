# frozen_string_literal: true

require "rails_helper"

describe Courses::Fetch do
  describe ".by_code" do
    let(:provider_code) { course.provider.provider_code }
    let(:course_code) { course.course_code }
    let(:recruitment_cycle_year) { course.recruitment_cycle.year }
    let(:course) { create(:course) }

    it "fetches a course by course_code" do
      expect(described_class.by_code(
               provider_code:,
               course_code:,
               recruitment_cycle_year:,
             )).to eq(course)
    end
  end

  describe ".by_accrediting_provider" do
    let(:provider) { create(:provider, provider_name: "Mid Provider") }
    let(:cycle) { provider.recruitment_cycle }

    it "groups the provider's courses by ratifying provider name, sorted by name, self-accredited under its own" do
      zebra = create(:accredited_provider, provider_name: "Zebra University", recruitment_cycle: cycle)
      apple = create(:accredited_provider, provider_name: "Apple University", recruitment_cycle: cycle)
      own_b = create(:course, provider:, name: "B own", course_code: "B1")
      own_a = create(:course, provider:, name: "A own", course_code: "A1")
      zebra_course = create(:course, provider:, name: "Zebra course", accredited_provider_code: zebra.provider_code)
      apple_course = create(:course, provider:, name: "Apple course", accredited_provider_code: apple.provider_code)

      grouped = described_class.by_accrediting_provider(provider)

      expect(grouped.keys).to eq(["Apple University", "Mid Provider", "Zebra University"])
      expect(grouped.transform_values { |courses| courses.map(&:id) }).to eq(
        "Apple University" => [apple_course.id],
        "Mid Provider" => [own_a.id, own_b.id],
        "Zebra University" => [zebra_course.id],
      )
      expect(grouped.values.flatten).to all(be_a(CourseDecorator))
    end

    # The copy-content sidebars call this on every edit page, so the ratifying
    # provider has to come with the courses rather than once per course.
    it "loads the courses in a constant number of queries regardless of how many there are" do
      accredited = create(:accredited_provider, recruitment_cycle: cycle)
      queries_for = lambda do |count|
        create_list(:course, count, provider:, accredited_provider_code: accredited.provider_code)
        count_queries { described_class.by_accrediting_provider(provider.reload) }
      end

      expect(queries_for.call(3)).to eq(queries_for.call(1))
    end
  end
end
