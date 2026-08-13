# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataHub::DuplicateSchools::Reporter do
  subject(:reporter) { described_class.new(groups:, years: [year], io: output) }

  let(:provider) { create(:provider) }
  let(:year) { provider.recruitment_cycle.year }
  let(:output) { StringIO.new }
  let(:groups) { DataHub::DuplicateSchools::Classifier.new(years: [year]).call }

  before do
    create(:gias_school, :open, urn: "144834", name: "Hilltop Infant School")
    site = create(:site, provider:, urn: "144834", code: "DK", location_name: "Hilltop Infant School")
    build(:site, provider:, urn: "144834", code: "DN", location_name: "Hilltop Infant School", postcode: site.postcode)
      .save(validate: false)
  end

  it "counts the groups by kind" do
    reporter.call

    expect(output.string).to include("split_code_twin", "groups")
  end

  it "leads each group with what its kind means and what to do about it" do
    reporter.call

    expect(output.string).to include(
      "one school held under two codes",
      "merge onto the code holding more courses",
    )
  end

  it "prints a CSV row per site, carrying its kind" do
    reporter.call

    csv_rows = output.string.lines.grep(/^#{year},/)

    expect(csv_rows.count).to eq(2)
    expect(csv_rows).to all(include("split_code_twin", "144834"))
  end
end
