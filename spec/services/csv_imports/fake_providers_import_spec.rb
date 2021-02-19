require "rails_helper"

RSpec.describe CSVImports::FakeProvidersImport do
  let(:csv_content) { "" }
  let(:csv_file)    { StringIO.new(csv_content) }

  before do
    allow(File).to receive(:open).with("csv_file.csv", anything, anything).and_return(csv_file)
  end

  context "one provider to import" do
    let(:csv_content) do
      "name,code,type,accredited_body\n\"Provider A\",ABC,scitt,false"
    end

    it "works" do
      described_class.new("csv_file.csv").execute
      created_provider = Provider.last

      expect(created_provider.provider_name).to eq("Provider A")
      expect(created_provider.provider_code).to eq("ABC")
      expect(created_provider.provider_type).to eq("scitt")
      expect(created_provider).not_to be_accredited_body
    end

    it "reports on the created provider" do
      import = described_class.new("csv_file.csv")
      import.execute

      expect(import.results).to eq(["Created provider Provider A."])
    end
  end

  context "two providers to import" do
    let(:csv_content) do
      "name,code,type,accredited_body\n\"Provider A\",ABC,scitt,false\n\"Provider B\",DEF,lead_school,false"
    end

    it "creates two providers" do
      expect {
        described_class.new("csv_file.csv").execute
      }.to change { Provider.count }.by(2)
    end

    it "reports on both created providers" do
      import = described_class.new("csv_file.csv")
      import.execute

      expect(import.results).to eq(["Created provider Provider A.", "Created provider Provider B."])
    end
  end

  context "when the CSV contains duplicated data" do
    let(:csv_content) do
      "name,code,type,accredited_body\n\"Provider A\",ABC,scitt,false\n\"Provider A\",ABC,lead_school,true"
    end

    it "reports on the created provider and the error" do
      import = described_class.new("csv_file.csv")
      import.execute

      expect(import.results).to eq(["Created provider Provider A.", "Provider Provider A (ABC) already exists."])
    end
  end
end
