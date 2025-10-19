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
      Timecop.freeze do
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
      end

      Timecop.travel 1.minute.from_now do
        expect { described_class.call(test_csv) }.not_to(change { GiasSchool.last.updated_at })
      end
    end
  end

  context "when existing school has coordinates but CSV has blank coordinates" do
    let!(:school_with_coords) do
      GiasSchool.create(
        urn: "200000",
        name: "School with Coordinates",
        address1: "123 Main St",
        town: "London",
        postcode: "SW1A 1AA",
        latitude: 51.5,
        longitude: -0.1,
      )
    end

    let!(:test_csv) do
      StringIO.new(<<~CSV_DATA)
        urn,name,type_code,group_code,status_code,phase_code,minimum_age,maximum_age,ukprn,address1,address2,address3,town,county,postcode,website,telephone,latitude,longitude
        200000,Updated School Name,02,4,1,2,3,11,10079319,456 New St,,,London,,SW1A 1AA,www.example.com,02012345678,,
      CSV_DATA
    end

    it "preserves existing coordinates when CSV has blank values" do
      subject

      expect(school_with_coords.reload).to have_attributes(
        name: "Updated School Name",
        address1: "456 New St",
        latitude: 51.5, # Preserved
        longitude: -0.1, # Preserved
      )
    end
  end

  context "when existing school has no coordinates and CSV has blank coordinates" do
    let!(:school_without_coords) do
      GiasSchool.create(
        urn: "300000",
        name: "School without Coordinates",
        address1: "789 Test Ave",
        town: "Manchester",
        postcode: "M1 1AA",
        latitude: nil,
        longitude: nil,
      )
    end

    let!(:test_csv) do
      StringIO.new(<<~CSV_DATA)
        urn,name,type_code,group_code,status_code,phase_code,minimum_age,maximum_age,ukprn,address1,address2,address3,town,county,postcode,website,telephone,latitude,longitude
        300000,Updated School,02,4,1,2,3,11,10079319,789 Test Ave,,,Manchester,,M1 1AA,www.example.com,02012345678,,
      CSV_DATA
    end

    it "keeps coordinates as nil when both existing and CSV are blank" do
      subject

      expect(school_without_coords.reload).to have_attributes(
        name: "Updated School",
        latitude: nil,
        longitude: nil,
      )
    end
  end

  context "when CSV has coordinates and existing school has none" do
    let!(:school_without_coords) do
      GiasSchool.create(
        urn: "400000",
        name: "School to be geocoded",
        address1: "999 New Rd",
        town: "Birmingham",
        postcode: "B1 1AA",
        latitude: nil,
        longitude: nil,
      )
    end

    let!(:test_csv) do
      StringIO.new(<<~CSV_DATA)
        urn,name,type_code,group_code,status_code,phase_code,minimum_age,maximum_age,ukprn,address1,address2,address3,town,county,postcode,website,telephone,latitude,longitude
        400000,School to be geocoded,02,4,1,2,3,11,10079319,999 New Rd,,,Birmingham,,B1 1AA,www.example.com,02012345678,52.4862,-1.8904
      CSV_DATA
    end

    it "updates with coordinates from CSV" do
      subject

      expect(school_without_coords.reload).to have_attributes(
        latitude: 52.4862,
        longitude: -1.8904,
      )
    end
  end
end
