# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Schools::ChangesSummaryComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(attached:)) { "the school checkboxes" }
  end

  let(:attached) { %w[uuid-one uuid-two] }

  def summary
    rendered.at_css("[data-schools-changes-target='summary']")
  end

  describe "the element the controller works on" do
    it "wraps the list it is given" do
      expect(rendered.text).to include("the school checkboxes")
    end

    it "tells the controller which schools are already attached" do
      expect(rendered.at_css("[data-controller='schools-changes']")["data-schools-changes-attached-value"])
        .to eq(%(["uuid-one","uuid-two"]))
    end

    # Each school says on its own row that it reports here, rather than the wrapper
    # listening for anything that happens to change inside it.
    it "does not listen on the wrapper" do
      expect(rendered.at_css("[data-controller='schools-changes']")["data-action"]).to be_nil
    end

    context "when nothing is attached yet, as in the add course wizard" do
      subject(:rendered) { render_inline(described_class.new) { "the school checkboxes" } }

      it "says so rather than leaving the controller to guess" do
        expect(rendered.at_css("[data-controller='schools-changes']")["data-schools-changes-attached-value"])
          .to eq("[]")
      end
    end
  end

  describe "the announcement" do
    def status
      rendered.at_css("[role='status']")
    end

    it "is a live region, so a change is announced without moving focus" do
      expect(status["aria-live"]).to eq("polite")
    end

    it "is hidden, since the summary itself is already on the page" do
      expect(status[:class]).to include("govuk-visually-hidden")
    end

    it "starts empty, so only a change is ever announced" do
      expect(status.text).to be_blank
    end

    # Counts, never the names: the list is already on the page under its own
    # heading, and reading forty schools aloud on every tick would be unusable.
    it "carries the wording for the controller to fill in" do
      expect(status["data-adding-one"]).to eq("Adding 1 school")
      expect(status["data-adding-other"]).to eq("Adding %{count} schools")
      expect(status["data-adding-all"]).to eq("Adding all schools")
      expect(status["data-removing-one"]).to eq("Removing 1 school")
      expect(status["data-removing-other"]).to eq("Removing %{count} schools")
      expect(status["data-removing-all"]).to eq("Removing all schools")
    end
  end

  # The shapes the controller fills in. They live here so that every GOV.UK class
  # is in the markup, where the rest of the page's are.
  describe "the templates" do
    def template(name)
      rendered.at_css("template[data-schools-changes-target='#{name}']")
    end

    it "gives a count its heading and its list" do
      expect(template("countTemplate").at_css("h3")[:class]).to eq("govuk-heading-s")
      expect(template("countTemplate").at_css("ul")[:class]).to eq("govuk-list govuk-list--bullet")
    end

    it "gives the all schools message a paragraph" do
      expect(template("messageTemplate").at_css("p")[:class]).to eq("govuk-body")
    end

    it "gives a school its list item" do
      expect(template("itemTemplate").at_css("li")).to be_present
    end
  end

  describe "the summary" do
    it "is hidden until the provider changes something" do
      expect(summary.attributes).to have_key("hidden")
    end

    it "heads the summary" do
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
      expect(added["data-other"]).to eq("You are adding %{count} schools:")
    end

    it "carries the wording for schools being removed" do
      removed = summary.at_css("[data-schools-changes-target='removed']")

      expect(removed["data-all"]).to eq("You are removing all schools in your list")
      expect(removed["data-one"]).to eq("You are removing 1 school:")
      expect(removed["data-other"]).to eq("You are removing %{count} schools:")
    end
  end
end
