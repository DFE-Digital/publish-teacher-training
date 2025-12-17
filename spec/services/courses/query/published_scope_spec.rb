# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::Query do # rubocop:disable RSpec/SpecFilePathFormat
  subject(:results) { described_class.call(params: {}) }

  describe "published filtering on site status" do
    context "when course has findable sites (running and published)" do
      let!(:course) do
        create(:course, name: "Findable Course").tap do |c|
          create(:site_status, :findable, course: c)
        end
      end

      it "includes the course" do
        expect(results).to include(course)
      end
    end

    context "when course has only suspended sites" do
      let!(:course) do
        create(:course, name: "Suspended Course").tap do |c|
          create(:site_status, course: c, status: :suspended, publish: :published)
        end
      end

      it "excludes the course" do
        expect(results).not_to include(course)
      end
    end

    context "when course has only unpublished sites" do
      let!(:course) do
        create(:course, name: "Unpublished Course").tap do |c|
          create(:site_status, course: c, status: :running, publish: :unpublished)
        end
      end

      it "excludes the course" do
        expect(results).not_to include(course)
      end
    end

    context "when course has no sites" do
      let!(:course) do
        create(:course, name: "No Sites Course")
      end

      it "excludes the course" do
        expect(results).not_to include(course)
      end
    end

    context "when course has a mix of suspended and findable sites" do
      let!(:course) do
        create(:course, name: "Mixed Sites Course").tap do |c|
          create(:site_status, course: c, status: :suspended, publish: :published)
          create(:site_status, :findable, course: c)
        end
      end

      it "includes the course because it has at least one findable site" do
        expect(results).to include(course)
      end
    end

    context "when course has discontinued sites" do
      let!(:course) do
        create(:course, name: "Discontinued Course").tap do |c|
          create(:site_status, course: c, status: :discontinued, publish: :published)
        end
      end

      it "excludes the course" do
        expect(results).not_to include(course)
      end
    end
  end
end
