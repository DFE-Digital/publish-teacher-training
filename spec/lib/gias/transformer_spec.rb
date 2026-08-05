# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gias::Transformer do
  subject { described_class.call(downloaded_csv.open) }

  let(:file_name) { "tmp/gias_school-#{Process.pid}.csv" }
  let(:downloaded_csv) do
    FileUtils.cp(file_fixture("lib/gias/downloaded.csv"), file_name)
    File.new(file_name)
  end

  it "when northing or easting is not present does not create a row and logs error" do
    allow(Gias::Log).to receive(:log).with(String, String)

    inline_csv = Tempfile.new
    inline_csv.write(<<~CSV)
      EstablishmentStatus (code),TypeOfEstablishment (code),Northing,Easting
      1,33,,
    CSV

    expected_csv = "urn,name,type_code,group_code,status_code,phase_code,minimum_age,maximum_age,ukprn,address1,address2,address3,town,county,postcode,website,telephone,region_code,latitude,longitude"
    actual_csv = described_class.call(inline_csv.open).read.chomp

    expect(Gias::Log).to have_received(:log).with("Gias::Transformer", "Starting transformation of GIAS schools download...")

    expect(File.exist?(file_name)).to be(false)
    expect(expected_csv).to eq(actual_csv)
  ensure
    inline_csv&.delete
    FileUtils.rm_f(file_name)
  end

  it "when the region code is not a valid English region does not create a row" do
    header = "EstablishmentStatus (code),TypeOfEstablishment (code),GOR (code),Northing,Easting"

    inline_csv = Tempfile.new
    inline_csv.write(<<~CSV)
      #{header}
      1,33,W,181851,532506
    CSV

    expected_csv = "urn,name,type_code,group_code,status_code,phase_code,minimum_age,maximum_age,ukprn,address1,address2,address3,town,county,postcode,website,telephone,region_code,latitude,longitude"
    actual_csv = described_class.call(inline_csv.open).read.chomp

    expect(expected_csv).to eq(actual_csv)
  ensure
    inline_csv&.delete
    FileUtils.rm_f(file_name)
  end

  it "filters out the columns we do not use" do
    actual_csv = described_class.call(downloaded_csv)
    actual_rows = CSV.parse(actual_csv.read, headers: true)
    actual_row = actual_rows.first.to_h

    expect(actual_rows.headers).to eq(
      %w[urn name type_code group_code status_code phase_code minimum_age maximum_age ukprn address1 address2 address3 town county postcode website telephone region_code latitude longitude],
    )

    expect(actual_row.except("latitude", "longitude")).to eq(
      "urn" => "100000",
      "name" => "The Aldgate School",
      "type_code" => "02",
      "group_code" => "4",
      "status_code" => "1",
      "phase_code" => "2",
      "minimum_age" => "3",
      "maximum_age" => "11",
      "ukprn" => "10079319",
      "address1" => "St James's Passage",
      "address2" => "Duke's Place",
      "address3" => "",
      "town" => "London",
      "county" => "",
      "postcode" => "EC3A 5DE",
      "website" => "www.thealdgateschool.org",
      "telephone" => "02072831147",
      "region_code" => "H",
    )
    expect(actual_row["latitude"].to_f).to be_within(0.0001).of(51.513968813644965)
    expect(actual_row["longitude"].to_f).to be_within(0.0001).of(-0.077530631715809)
  ensure
    FileUtils.rm_f(file_name)
    actual_csv&.delete
  end
end
