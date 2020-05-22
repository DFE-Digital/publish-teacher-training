require "rails_helper"

RSpec.describe AllocationImporterService do
  # disable stdout
  around do |example|
    original_stdout = $stdout
    $stdout = File.open(File::NULL, "w")
    example.run
    $stdout = original_stdout
  end

  let(:recruitment_cycle) { find_or_create(:recruitment_cycle, id: 1) }
  let(:path_to_csv) { Rails.root.join("tmp/physical_education.csv") }
  let(:training_provider) { create(:provider, recruitment_cycle: recruitment_cycle) }
  let(:accredited_body_provider) { create(:provider, :accredited_body, recruitment_cycle: recruitment_cycle) }

  subject do
    described_class.new(path_to_csv: path_to_csv)
  end

  describe "#execute" do
    context "happy path" do
      before do
        File.open(path_to_csv, "w") do |f|
          f.write "provider,provider_code,accredited_body,accredited_body_code,number_of_places\n"
          f.write "#{training_provider.provider_name},#{training_provider.provider_code},#{accredited_body_provider.provider_name},#{accredited_body_provider.provider_code},3\n"
        end
      end

      it "creates correct allocation" do
        expect { subject.execute }.to change(Allocation, :count).by(1)

        allocation = Allocation.last

        expect(allocation.provider_id).to eql(training_provider.id)
        expect(allocation.accredited_body_id).to eql(accredited_body_provider.id)
        expect(allocation.number_of_places).to eql(3)
        expect(allocation.provider_code).to eql(training_provider.provider_code)
        expect(allocation.accredited_body_code).to eql(accredited_body_provider.provider_code)
      end

      it "is idempotent" do
        expect {
          subject.execute
          subject.execute
        }.to change(Allocation, :count).by(1)
      end
    end

    context "when training provider not found" do
      before do
        File.open(path_to_csv, "w") do |f|
          f.write "allocation,training_provider_code,accredited_body_provider_code\n"
          f.write "3,no-provider,#{accredited_body_provider.provider_code}\n"
        end
      end

      it "raises an error" do
        expect { subject.execute }.to raise_error(RuntimeError)
      end
    end

    context "when accredited body provider not found" do
      before do
        File.open(path_to_csv, "w") do |f|
          f.write "allocation,training_provider_code,accredited_body_provider_code\n"
          f.write "3,#{training_provider.provider_code},no-provider\n"
        end
      end

      it "raises an error" do
        expect { subject.execute }.to raise_error(RuntimeError)
      end
    end
  end
end
