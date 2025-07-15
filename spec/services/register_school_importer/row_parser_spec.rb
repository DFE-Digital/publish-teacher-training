require "rails_helper"

RSpec.describe RegisterSchoolImporter::RowParser do
  subject(:parser) { described_class.new(row) }

  let(:row) do
    {
      "register_accredited_provider_code" => "133",
      "provider_code" => " 12K ",
      "placement_urns" => '["97267X","51146Y"]',
    }
  end

  describe "#provider_code" do
    it "returns provider_code if present" do
      expect(parser.provider_code).to eq("12K")
    end

    it "returns accredited_provider_code if provider_code is blank" do
      row["provider_code"] = ""
      expect(parser.provider_code).to eq("133")
    end

    it "returns nil if both codes are blank" do
      row["provider_code"] = " "
      row["register_accredited_provider_code"] = ""
      expect(parser.provider_code).to be_nil
    end
  end

  describe "#urns" do
    it "returns all URNs as strings when JSON array is present" do
      row["placement_urns"] = '["972671", "511463"]'
      expect(parser.urns).to eq(%w[972671 511463])
    end

    it "handles unquoted string URNs and returns as strings" do
      row["placement_urns"] = "[97267X,51146Y]"
      expect(parser.urns).to eq(%w[97267X 51146Y])
    end

    it "handles single URN arrays" do
      row["placement_urns"] = '["230153"]'
      expect(parser.urns).to eq(%w[230153])
    end

    it "handles comma+space separation" do
      row["placement_urns"] = "[ 108852 , 115046 , 601996 ]"
      expect(parser.urns).to eq(%w[108852 115046 601996])
    end

    it "returns empty array if placement_urns missing" do
      row.delete("placement_urns")
      expect(parser.urns).to eq([])
    end

    it "returns empty array if placement_urns is blank" do
      row["placement_urns"] = ""
      expect(parser.urns).to eq([])
    end
  end
end
