# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gias::Transformer do
  subject { described_class.call(downloaded_csv.open) }

  let(:downloaded_csv) do
    FileUtils.cp(file_fixture("lib/gias/downloaded.csv"), "tmp/gias_school.csv")
    File.new("tmp/gias_school.csv")
  end

  it "when northing or easting is not present does not create a row and logs error" do
    allow(Gias::Log).to receive(:log).with(String, String)

    inline_csv = Tempfile.new
    inline_csv.write(<<~CSV)
      EstablishmentStatus (code),TypeOfEstablishment (code),Northing,Easting
      1,33,,
    CSV

    expected_csv = "urn,name,type_code,group_code,status_code,phase_code,minimum_age,maximum_age,ukprn,address1,address2,address3,town,county,postcode,website,telephone,latitude,longitude"
    actual_csv = described_class.call(inline_csv.open).read.chomp

    expect(Gias::Log).to have_received(:log).with("Gias::Transformer", "Starting transformation of GIAS schools download...")

    expect(File.exist?("tmp/gias_school.csv")).to be(false)
    expect(expected_csv).to eq(actual_csv)
  ensure
    inline_csv&.delete
    FileUtils.rm_f("tmp/gias_school.csv")
  end

  it "filters out the columns we do not use" do
    expected_csv = <<~EXPECTEDCSV
      urn,name,type_code,group_code,status_code,phase_code,minimum_age,maximum_age,ukprn,address1,address2,address3,town,county,postcode,website,telephone,latitude,longitude
      100000,The Aldgate School,02,4,1,2,3,11,10079319,St James's Passage,Duke's Place,"",London,"",EC3A 5DE,www.thealdgateschool.org,02072831147,51.513968813644965,-0.077530631715809
    EXPECTEDCSV

    actual_csv = described_class.call(downloaded_csv)
    expect(actual_csv.read).to eq(expected_csv)
  ensure
    FileUtils.rm_f("tmp/gias_school.csv")
    actual_csv&.delete
  end
end
