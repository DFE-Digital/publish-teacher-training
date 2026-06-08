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
