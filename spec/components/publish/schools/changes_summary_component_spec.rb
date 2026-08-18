# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Schools::ChangesSummaryComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(attached:)) { "the school checkboxes" }
  end

  let(:attached) { %w[uuid-one uuid-two] }

  def summary
    rendered.at_css(".app-schools-changes")
  end

  describe "the element the controller works on" do
    it "wraps the list it is given" do
      expect(rendered.text).to include("the school checkboxes")
    end

    it "tells the controller which schools are already attached" do
      expect(rendered.at_css("[data-controller='schools-changes']")["data-schools-changes-attached-value"])
        .to eq(%(["uuid-one","uuid-two"]))
    end

    it "listens for any checkbox in the list changing" do
      expect(rendered.at_css("[data-controller='schools-changes']")["data-action"])
        .to eq("change->schools-changes#update")
    end

    context "when nothing is attached yet, as in the add course wizard" do
      subject(:rendered) { render_inline(described_class.new) { "the school checkboxes" } }

      it "says so rather than leaving the controller to guess" do
        expect(rendered.at_css("[data-controller='schools-changes']")["data-schools-changes-attached-value"])
          .to eq("[]")
      end
    end
  end

  describe "the summary" do
    it "is hidden until the provider changes something" do
      expect(summary.attributes).to have_key("hidden")
    end

    it "heads the play-back" do
      expect(summary.text).to include("You are updating these schools")
    end

    it "leaves the two sections empty for the controller to fill in" do
      expect(summary.at_css("[data-schools-changes-target='added']").text).to be_blank
      expect(summary.at_css("[data-schools-changes-target='removed']").text).to be_blank
    end

    it "carries the wording for schools being added" do
      added = summary.at_css("[data-schools-changes-target='added']")

      expect(added["data-all"]).to eq("You are adding all schools in your list")
      expect(added["data-one"]).to eq("You are adding 1 school:")
      expect(added["data-other"]).to eq("You are adding {count} schools:")
    end

    it "carries the wording for schools being removed" do
      removed = summary.at_css("[data-schools-changes-target='removed']")

      expect(removed["data-all"]).to eq("You are removing all schools in your list")
      expect(removed["data-one"]).to eq("You are removing 1 school:")
      expect(removed["data-other"]).to eq("You are removing {count} schools:")
    end
  end
end
