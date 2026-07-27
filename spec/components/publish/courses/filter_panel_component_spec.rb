# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Courses::FilterPanelComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(filter_form:, provider:, **options)) }

  let(:provider) { create(:provider) }
  let(:attributes) { {} }
  let(:options) { {} }
  let(:filter_form) { Publish::CourseFilterForm.new(provider:, **attributes) }

  def group_headings
    rendered.css(".app-c-filter-section__summary-heading").map { |heading| heading.text.strip }
  end

  describe "the panel" do
    it "is headed Filter courses" do
      expect(rendered.css("h2").text).to include("Filter courses")
    end

    it "submits back to the course list as a GET" do
      form = rendered.css("form").first

      expect(form[:method]).to eq("get")
      expect(form[:action]).to eq(
        "/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/courses",
      )
    end

    it "applies the filters with a button" do
      expect(rendered.css("button[type='submit']").text).to include("Apply filters")
    end

    it "does not auto-submit as checkboxes change" do
      form = rendered.css("form").first

      expect(form["data-controller"]).to be_nil
      expect(form["data-action"]).to be_nil
    end
  end

  describe "the filter groups" do
    it "renders one collapsible section per group, in order" do
      expect(rendered.css("details.app-c-filter-section").size).to eq(6)
      expect(group_headings).to eq(
        ["Status", "Education phase", "Fee or salary", "Qualification", "Full time or part time", "Start date"],
      )
    end

    it "names the checkboxes so each group arrives as an array" do
      expect(rendered.css("input[type='checkbox']").map { |input| input[:name] }.uniq)
        .to eq(["status[]", "level[]", "funding[]", "qualification[]", "study_mode[]", "start_date[]"])
    end

    it "offers every status the list can show" do
      labels = rendered.css("input[name='status[]']").map { |input| rendered.css("label[for='#{input[:id]}']").text.strip }

      expect(labels).to eq(["Open", "Closed", "Draft", "Rolled over", "Scheduled", "Withdrawn"])
    end

    it "offers every month in the cycle window as a start date" do
      expect(rendered.css("input[name='start_date[]']").size).to eq(19)
    end

    context "when only some groups are visible" do
      let(:options) { { visible_groups: %i[status funding] } }

      it "renders only those" do
        expect(group_headings).to eq(["Status", "Fee or salary"])
      end
    end
  end

  describe "the selected options" do
    let(:attributes) { { status: %w[open closed], level: %w[primary] } }

    it "ticks them" do
      checked = rendered.css("input[type='checkbox'][checked]").map { |input| input[:value] }

      expect(checked).to contain_exactly("open", "closed", "primary")
    end

    it "says how many are selected in each group" do
      counts = rendered.css(".app-c-filter-section").to_h do |section|
        [section.css(".app-c-filter-section__summary-heading").text.strip, section.css(".app-c-filter-section__count").text.strip]
      end

      expect(counts["Status"]).to eq("2 selected")
      expect(counts["Education phase"]).to eq("1 selected")
    end

    it "leaves the hint off groups with nothing selected" do
      funding = rendered.css(".app-c-filter-section").find { |s| s.text.include?("Fee or salary") }

      expect(funding.css(".app-c-filter-section__count")).to be_empty
    end

    it "keeps every group collapsed, even those with a selection" do
      expect(rendered.css("details[open]")).to be_empty
    end
  end

  describe "the active filters" do
    context "when filters are applied" do
      let(:attributes) { { status: %w[open], level: %w[primary] } }

      it "shows a chip for each one" do
        expect(rendered.css(".app-active-filters__remove-filter").map { |chip| chip.text.gsub("Remove filter", "").strip })
          .to eq(%w[Open Primary])
      end

      it "links each chip back to the course list without that filter" do
        expect(rendered.css(".app-active-filters__remove-filter").first[:href]).to eq(
          "/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/courses?level%5B%5D=primary",
        )
      end

      it "offers a way to clear them all" do
        clear_all = rendered.css(".app-c-filter-summary__clear-filters").first

        expect(clear_all.text.strip).to eq("Clear all")
        expect(clear_all[:href]).to eq(
          "/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/courses",
        )
      end
    end

    context "when no filters are applied" do
      it "shows no chips" do
        expect(rendered.css(".app-active-filters")).to be_empty
      end
    end
  end
end
