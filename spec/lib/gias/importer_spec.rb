# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gias::Importer do
  subject { described_class.call(test_csv) }

  let(:test_csv) { file_fixture("lib/gias/transformed.csv") }

  let(:school) do
    GiasSchool.create(
      urn: "100000",
      name: "Old Name",
      address1: "Old address",
      town: "Old town",
      postcode: "OL 123",
    )
  end

  it "updates the GiasSchool with the same urn" do
    school
    subject
    expect(school.reload).to have_attributes(
      { urn: "100000",
        name: "The Aldgate School",
        type_code: "02",
        group_code: "4",
        status_code: "1",
        phase_code: "2",
        minimum_age: "3",
        maximum_age: "11",
        ukprn: "10079319",
        address1: "St James's Passage",
        address2: "Duke's Place",
        address3: "",
        town: "London",
        county: "",
        postcode: "EC3A 5DE",
        website: "www.thealdgateschool.org",
        telephone: "02072831147",
        searchable: "'100000':1 '123':7 'name':3,5 'ol':6 'ol123':8 'old':2,4,9 'town':10",
        latitude: 51.513968813644965,
        longitude: -0.077530631715809 },
    )
  end
end
