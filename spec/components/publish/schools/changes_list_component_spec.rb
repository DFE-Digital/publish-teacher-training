# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Schools::ChangesListComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(changes:)) }

  let(:changes) { instance_double(Publish::Schools::SchoolChanges, **defaults) }

  let(:defaults) do
    {
      changed?: true,
      added_names: [],
      removed_names: [],
      adding_all?: false,
      removing_all?: false,
    }
  end

  def change(**overrides)
    instance_double(Publish::Schools::SchoolChanges, **defaults.merge(overrides))
  end

  def headings
    rendered.css("h3, .govuk-details__summary-text").map { |node| node.text.strip }
  end

  def items
    rendered.css("li").map(&:text)
  end

  it "heads the section" do
    expect(rendered.text).to include("You are updating these schools")
  end

  context "when nothing changed" do
    let(:changes) { change(changed?: false) }

    it "says so" do
      expect(rendered.text).to include("No placement schools added or removed")
      expect(items).to be_empty
    end
  end

  context "when schools are being added and removed" do
    let(:changes) { change(added_names: ["Ash Academy", "Beech School"], removed_names: ["Cedar School"]) }

    it "counts and names each half" do
      expect(headings).to eq(["You are adding 2 schools:", "You are removing 1 school:"])
      expect(items).to eq(["Ash Academy", "Beech School", "Cedar School"])
    end

    it "leaves both lists open" do
      expect(rendered.css("details")).to be_empty
    end
  end

  context "when every school in the list is being added" do
    let(:changes) { change(added_names: ["Cedar School"], adding_all?: true) }

    it "says so instead of counting" do
      expect(rendered.text).to include("You are adding all schools in your list")
      expect(items).to be_empty
    end
  end

  context "when every school in the list is being removed" do
    let(:changes) { change(removed_names: ["Ash Academy"], removing_all?: true) }

    it "says so instead of counting" do
      expect(rendered.text).to include("You are removing all schools in your list")
      expect(items).to be_empty
    end
  end

  describe "the point at which the lists collapse" do
    def names(count)
      Array.new(count) { |index| "School #{index + 1}" }
    end

    it "leaves them open below the threshold" do
      result = render_inline(described_class.new(changes: change(added_names: names(8), removed_names: names(8))))

      expect(result.css("details")).to be_empty
    end

    # Both halves move together: one open beside one collapsed reads as though
    # the collapsed half were the lesser change.
    it "collapses both once either half reaches it" do
      result = render_inline(described_class.new(changes: change(added_names: names(9), removed_names: names(1))))

      expect(result.css("details").size).to eq(2)
      expect(result.css(".govuk-details__summary-text").map { |node| node.text.strip })
        .to eq(["You are adding 9 schools", "You are removing 1 school"])
    end

    it "collapses both when it is the removals that reach it" do
      result = render_inline(described_class.new(changes: change(added_names: names(1), removed_names: names(9))))

      expect(result.css("details").size).to eq(2)
    end

    it "collapses the only half there is" do
      result = render_inline(described_class.new(changes: change(added_names: names(9))))

      expect(result.css("details").size).to eq(1)
    end
  end
end
