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
