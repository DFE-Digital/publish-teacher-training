# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::Query do # rubocop:disable RSpec/SpecFilePathFormat
  subject(:results) { described_class.call(params:) }

  let(:params) { {} }

  describe "base scope guarantees" do
    context "when a findable course has been discarded" do
      let!(:course) do
        create(:course, :published, :deleted, name: "Discarded Findable").tap do |c|
          create(:site_status, :findable, course: c)
        end
      end

      it "excludes the course" do
        expect(results).not_to include(course)
      end
    end

    context "when a findable course belongs to a previous recruitment cycle" do
      let!(:course) do
        previous_cycle = create(:recruitment_cycle, :previous)
        create(:course, :published, name: "Previous Cycle Findable", provider: create(:provider, recruitment_cycle: previous_cycle)).tap do |c|
          create(:site_status, :findable, course: c)
        end
      end

      it "excludes the course" do
        expect(results).not_to include(course)
      end
    end
  end

  describe "#count with active filters" do
    let(:params) { { funding: "salary" } }

    before do
      create(:course, :with_salary, :published, name: "Salary One").tap { |c| create(:site_status, :findable, course: c) }
      create(:course, :with_salary, :published, name: "Salary Two").tap { |c| create(:site_status, :findable, course: c) }
      create(:course, :fee, :published, name: "Fee One").tap { |c| create(:site_status, :findable, course: c) }
    end

    it "counts only the courses matching the filter" do
      query = described_class.new(params:)
      query.call

      expect(query.count).to eq(2)
    end
  end
end
