require "rails_helper"
require "nokogiri"

RSpec.describe Support::RecruitmentCyclesHelper do
  describe "#recruitment_cycle_status_tag" do
    subject(:tag_html) { helper.recruitment_cycle_status_tag(recruitment_cycle) }

    let(:tag) { Nokogiri::HTML.fragment(tag_html).at_css("strong.govuk-tag") }

    context "with current cycle" do
      let(:recruitment_cycle) { build(:recruitment_cycle) }

      it "returns green 'Current' tag" do
        allow(recruitment_cycle).to receive(:current?).and_return(true)

        expect(tag.text).to eq("Current")
      end
    end

    context "with upcoming cycle" do
      let(:recruitment_cycle) { build(:recruitment_cycle, :next, application_start_date: Date.tomorrow) }

      it "returns yellow 'Upcoming' tag" do
        expect(tag.text).to eq("Upcoming")
      end
    end

    context "with inactive cycle" do
      let(:recruitment_cycle) { build(:recruitment_cycle, :previous) }

      it "returns grey 'Past' tag" do
        expect(tag.text).to eq("Past")
      end
    end
  end
end
