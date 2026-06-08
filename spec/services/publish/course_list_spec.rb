# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::CourseList do
  subject(:course_list) { described_class.new(provider: provider.reload) }

  # Maps the built groups to a comparable structure: [heading, [course codes...]]
  def grouped
    course_list.groups.map { |group| [group.heading, group.courses.map(&:course_code)] }
  end

  describe "#groups" do
    context "when a self-accredited provider has its own courses" do
      let(:provider) { create(:provider, :accredited_provider) }

      before { create_list(:course, 3, provider:) }

      it "returns a single self-accredited group with no heading" do
        expect(course_list.groups.size).to eq(1)
        expect(course_list.groups.first).to be_self_accredited
        expect(course_list.groups.first.heading).to be_nil
      end

      it "includes all of the provider's courses in that group" do
        expect(course_list.groups.first.courses.size).to eq(3)
      end
    end

    context "when a lead-school provider has courses under one accredited provider" do
      let(:provider) { create(:provider) }
      let(:accredited_provider) { create(:accredited_provider, provider_name: "Zeta University") }

      before do
        create_list(:course, 2, provider:, accrediting_provider: accredited_provider)
      end

      it "returns a single headed group named after the accredited provider" do
        expect(course_list.groups.size).to eq(1)
        expect(course_list.groups.first).not_to be_self_accredited
        expect(course_list.groups.first.heading).to eq("Zeta University")
      end
    end

    context "when courses span multiple accredited providers" do
      let(:provider) { create(:provider) }

      before do
        create(:course, provider:, accrediting_provider: create(:accredited_provider, provider_name: "Banana College"))
        create(:course, provider:, accrediting_provider: create(:accredited_provider, provider_name: "apple Academy"))
        create(:course, provider:, accrediting_provider: create(:accredited_provider, provider_name: "Cherry Trust"))
      end

      it "orders groups case-insensitively by accredited provider name" do
        expect(course_list.groups.map(&:heading)).to eq(["apple Academy", "Banana College", "Cherry Trust"])
      end
    end

    context "when the provider has both self-accredited courses and ratified courses" do
      let(:provider) { create(:provider, :accredited_provider, provider_name: "Mid Provider") }

      before do
        create(:course, provider:)
        create(:course, provider:, accrediting_provider: create(:accredited_provider, provider_name: "Zoo College"))
        create(:course, provider:, accrediting_provider: create(:accredited_provider, provider_name: "Aardvark University"))
      end

      it "always orders the self-accredited group first, then the rest alphabetically" do
        expect(course_list.groups.map(&:heading)).to eq([nil, "Aardvark University", "Zoo College"])
        expect(course_list.groups.first).to be_self_accredited
      end
    end

    context "when a course has no accredited provider" do
      let(:provider) { create(:provider, :accredited_provider) }

      before do
        create(:course, provider:, accrediting_provider: nil)
        create(:course, provider:, accrediting_provider: create(:accredited_provider, provider_name: "Other University"))
      end

      it "folds the course into the self-accredited group" do
        self_group = course_list.groups.find(&:self_accredited?)

        expect(self_group.courses.size).to eq(1)
        expect(course_list.groups.map(&:heading)).to contain_exactly(nil, "Other University")
      end
    end

    context "within a group" do
      let(:provider) { create(:provider) }
      let(:accredited_provider) { create(:accredited_provider, provider_name: "One University") }

      before do
        create(:course, provider:, accrediting_provider: accredited_provider, name: "Biology", course_code: "B200")
        create(:course, provider:, accrediting_provider: accredited_provider, name: "Art", course_code: "A100")
        create(:course, provider:, accrediting_provider: accredited_provider, name: "Biology", course_code: "B100")
      end

      it "orders courses by name then course code" do
        expect(grouped).to eq([["One University", %w[A100 B100 B200]]])
      end
    end

    context "when the provider has no courses" do
      let(:provider) { create(:provider) }

      it "returns no groups" do
        expect(course_list.groups).to be_empty
        expect(course_list.any?).to be(false)
      end
    end
  end
end
