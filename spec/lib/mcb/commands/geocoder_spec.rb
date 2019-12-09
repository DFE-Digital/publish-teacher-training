require "mcb_helper"

describe "mcb geocode" do
  def execute_cmd(arguments: [], input: [])
    with_stubbed_stdout(stdin: input.join("\n")) do
      $mcb.run(["geocode", *arguments])
    end
  end

  let(:email) { "user@education.gov.uk" }
  let(:next_cycle) { find_or_create :recruitment_cycle, :next }
  let(:organisation) { create(:organisation) }
  let(:provider) { create :provider, provider_name: "Z", updated_at: 1.day.ago, changed_at: 1.day.ago, recruitment_cycle: next_cycle }
  let(:second_provider) { create :provider, provider_name: "Y", updated_at: 1.day.ago, changed_at: 1.day.ago, recruitment_cycle: next_cycle }

  before do
    allow(MCB).to receive(:init_rails)
  end

  context "Geocoding providers" do
    let!(:requester) { create(:user, email: email, organisations: [organisation]) }

    it "raises an error if user does not pass in the model (-m) arg" do
      expect { execute_cmd }.
        to raise_error(RuntimeError, /Please pass in the model you want to geocode/)
    end

    it "raises an error if user tries to geocode and invalid model" do
      expect { execute_cmd(arguments: %w(-m Course)) }.
        to raise_error(RuntimeError, /You can only geocode Sites and Providers/)
    end

    it "geocodes all Providers not currently geocoded" do
      expect { execute_cmd(arguments: %w(-m Provider)) }
        .to change { provider.reload.longitude }.from(nil).to(-0.1204749)
              .and change { provider.reload.latitude }.from(nil).to(51.4524877)
    end

    it "geocodes Providers by id" do
      expect { execute_cmd(arguments: ["-m", "Provider", second_provider.id]) }
        .to change { second_provider.reload.latitude }.from(nil).to(51.4524877)
              .and change { second_provider.reload.longitude }.from(nil).to(-0.1204749)

      expect(provider.reload.latitude).to be(nil)
      expect(provider.reload.longitude).to be(nil)
    end

    it "raises and error when it cannot find a provider" do
      unknown_id = 123
      expect { execute_cmd(arguments: ["-m", "Provider", unknown_id]) }.
        to raise_error(ActiveRecord::RecordNotFound, /Couldn't find Provider/)
    end
  end
end
