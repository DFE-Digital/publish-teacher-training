require "mcb_helper"

describe "mcb geocode" do
  def execute_cmd(arguments: [], input: [])
    with_stubbed_stdout(stdin: input.join("\n")) do
      $mcb.run(["providers", "geocode", *arguments])
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
    let(:default_sleep) { 0.25 }

    it "geocodes all Providers not currently geocoded" do
      expect(MCB).to receive(:geocode).with(obj: provider, sleep: default_sleep).and_call_original

      expect { execute_cmd }
        .to change { provider.reload.longitude }.from(nil).to(-0.1204749)
              .and change { provider.reload.latitude }.from(nil).to(51.4524877)
    end

    it "geocodes Providers by provider code" do
      expect(MCB).to receive(:geocode).with(obj: second_provider, sleep: default_sleep).and_call_original

      expect { execute_cmd(arguments: [second_provider.provider_code]) }
        .to change { second_provider.reload.latitude }.from(nil).to(51.4524877)
              .and change { second_provider.reload.longitude }.from(nil).to(-0.1204749)

      expect(provider.reload.latitude).to be(nil)
      expect(provider.reload.longitude).to be(nil)
    end
  end
end
