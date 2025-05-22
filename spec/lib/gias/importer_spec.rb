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
        searchable: "'100000':1 '5de':9 'aldgate':3,6 'ec3a':8 'ec3a5de':10 'london':11 'school':4,7 'the':2,5",
        latitude: 51.513968813644965,
        longitude: -0.077530631715809 },
    )
  end

  context "when school hasn't changed" do
    let!(:test_csv) do
      StringIO.new(<<~CSV_DATA)
        urn,name,type_code,group_code,status_code,phase_code,minimum_age,maximum_age,ukprn,address1,address2,address3,town,county,postcode,website,telephone,latitude,longitude
        100000,The Aldgate School,02,4,1,2,3,11,10079319,St James's Passage,Duke's Place,"","","",EC3A 5DE,www.thealdgateschool.org,02072831147,51.513968813644965,-0.077530631715809
      CSV_DATA
    end

    it "does not save the school again" do
      freeze_time
      now = Time.zone.now

      described_class.call(test_csv)

      school = GiasSchool.last

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
          town: "",
          county: "",
          postcode: "EC3A 5DE",
          website: "www.thealdgateschool.org",
          telephone: "02072831147",
          searchable: "'100000':1 '5de':9 'aldgate':3,6 'ec3a':8 'ec3a5de':10 'school':4,7 'the':2,5",
          latitude: 51.513968813644965,
          longitude: -0.077530631715809 },
      )

      expect(GiasSchool.last.updated_at).to be_within(1.second).of(now)

      travel_to 1.minute.from_now do
        expect { described_class.call(test_csv) }.not_to(change { GiasSchool.last.updated_at })
      end
    end
  end
end
