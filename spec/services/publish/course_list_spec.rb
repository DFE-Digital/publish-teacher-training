# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::CourseList do
  subject(:course_list) { described_class.new(provider: provider.reload) }

  describe "#groups" do
    let(:provider) { create(:provider, :accredited_provider, provider_name: "Mid Provider") }

    before do
      create(:course, provider:)
      create(:course, provider:, accrediting_provider: create(:accredited_provider, provider_name: "Other University"))
    end

    it "delegates to ProviderCoursesQuery, self-accredited group first" do
      expect(course_list.groups.map(&:heading)).to eq([nil, "Other University"])
    end
  end

  describe "filtering" do
    let(:provider) { create(:provider, :accredited_provider) }

    before do
      create(:course, :primary, provider:, name: "Primary course")
      create(:course, :secondary, provider:, name: "Secondary course")
    end

    it "lists every course when no filters are given" do
      expect(course_list.groups.flat_map(&:courses).map(&:name)).to contain_exactly("Primary course", "Secondary course")
    end

    it "passes the filters on to the query" do
      filtered = described_class.new(provider: provider.reload, params: { level: %w[secondary] })

      expect(filtered.groups.flat_map(&:courses).map(&:name)).to eq(["Secondary course"])
    end

    it "drops a group entirely when none of its courses match" do
      other = create(:accredited_provider, provider_name: "Other University")
      create(:course, :primary, provider:, accrediting_provider: other, name: "Ratified primary")

      filtered = described_class.new(provider: provider.reload, params: { level: %w[secondary] })

      expect(filtered.groups.map(&:heading)).to eq([nil])
    end

    it "reports whether anything matched" do
      filtered = described_class.new(provider: provider.reload, params: { level: %w[further_education] })

      expect(filtered.any?).to be(false)
    end
  end

  describe "#visible_course_information_fields" do
    let(:provider) { create(:provider, :accredited_provider) }

    context "when every course shares the same values" do
      before { create_list(:course, 2, :without_validation, provider:) }

      it "returns no fields" do
        expect(course_list.visible_course_information_fields).to eq([])
      end
    end

    context "when only one field varies across the courses" do
      before do
        create(:course, :without_validation, provider:, study_mode: :full_time)
        create(:course, :without_validation, provider:, study_mode: :part_time)
      end

      it "returns just that field" do
        expect(course_list.visible_course_information_fields).to eq([:study_mode])
      end
    end

    context "when several fields vary" do
      before do
        create(:course, :without_validation, provider:, funding: "fee", study_mode: :full_time)
        create(:course, :without_validation, provider:, funding: "salary", study_mode: :part_time)
      end

      it "returns the varying fields in display order" do
        expect(course_list.visible_course_information_fields).to eq(%i[funding study_mode])
      end
    end

    context "when a field is uniform within each group but differs between groups" do
      before do
        create(:course, :without_validation, provider:, study_mode: :full_time)
        create(:course, :without_validation, provider:, study_mode: :part_time,
                                             accrediting_provider: create(:accredited_provider, provider_name: "Other University"))
      end

      it "treats uniformity across the whole list, not per group" do
        expect(course_list.groups.size).to eq(2)
        expect(course_list.visible_course_information_fields).to eq([:study_mode])
      end
    end

    context "with start dates" do
      it "hides the start date when every course is missing one" do
        create_list(:course, 2, :without_validation, provider:, start_date: nil)

        expect(course_list.visible_course_information_fields).to eq([])
      end

      it "shows the start date when some courses have one and others do not" do
        create(:course, :without_validation, provider:, start_date: nil)
        create(:course, :without_validation, provider:, start_date: Time.zone.local(2026, 9, 1))

        expect(course_list.visible_course_information_fields).to eq([:start_date])
      end
    end

    # The column decision is a property of the whole list, so filtering must not
    # change it: a field that varies across every course stays shown even once
    # the list is narrowed to a single value, and a uniform field stays hidden.
    context "when the list is filtered" do
      before do
        create(:course, :without_validation, provider:, funding: "fee")
        create(:course, :without_validation, provider:, funding: "salary")
      end

      it "keeps a field that varies across the whole list when filtered to one value" do
        filtered = described_class.new(provider: provider.reload, params: { funding: %w[fee] })

        expect(filtered.groups.flat_map(&:courses).size).to eq(1)
        expect(filtered.visible_course_information_fields).to include(:funding)
      end
    end

    context "when a field is uniform across the whole list but the list is filtered" do
      before do
        create(:course, :primary, :without_validation, provider:, funding: "fee")
        create(:course, :secondary, :without_validation, provider:, funding: "fee")
      end

      it "keeps the uniform field hidden" do
        filtered = described_class.new(provider: provider.reload, params: { level: %w[primary] })

        expect(filtered.groups.flat_map(&:courses).size).to eq(1)
        expect(filtered.visible_course_information_fields).not_to include(:funding)
      end
    end
  end

  describe "enumerable facade" do
    let(:provider) { create(:provider, :accredited_provider) }

    context "when the provider has courses" do
      before { create_list(:course, 2, provider:) }

      it "is enumerable over its groups" do
        expect(course_list.map(&:courses).flatten.size).to eq(2)
      end

      it "reports that it has groups" do
        expect(course_list.any?).to be(true)
      end
    end

    context "when the provider has no courses" do
      it "is empty" do
        expect(course_list.any?).to be(false)
        expect(course_list.groups).to be_empty
      end
    end
  end
end
