require "rails_helper"

RSpec.describe UkprnUrnImporterService do
  let(:path_to_csv) { Rails.root.join("tmp/ukprn_urn_lookup.csv") }
  let(:provider) { create(:provider) }

  subject do
    described_class.new(path_to_csv: path_to_csv)
  end

  describe "#execute" do
    context "happy path" do
      before do
        File.open(path_to_csv, "w") do |f|
          f.write "provider_code,urn,ukprn\n"
          f.write "#{provider.provider_code},,my_ukprn\n"
          f.write "#{provider.provider_code},my_urn,\n"
        end
      end

      it "updates ukprn and urn" do
        expect(provider.ukprn).to be_nil
        expect(provider.urn).to be_nil

        subject.execute

        provider.reload

        expect(provider.urn).to eql("my_urn")
        expect(provider.ukprn).to eql("my_ukprn")
      end
    end

    context "when provider not found" do
      before do
        File.open(path_to_csv, "w") do |f|
          f.write "provider_code,urn,ukprn\n"
          f.write "invalid-provider-code,my_urn,\n"
        end
      end

      it "raises an error" do
        expect { subject.execute }.to raise_error(RuntimeError)
      end
    end

    context "when incorrect format" do
      before do
        File.open(path_to_csv, "w") do |f|
          f.write "provider_code,URN,ukprn\n"
        end
      end

      it "raises an error" do
        expect { subject.execute }.to raise_error(RuntimeError)
      end
    end
  end
end
