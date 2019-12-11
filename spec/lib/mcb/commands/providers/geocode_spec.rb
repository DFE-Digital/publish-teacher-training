require "mcb_helper"

describe "mcb geocode" do
  def execute_cmd(arguments: [], input: [])
    with_stubbed_stdout(stdin: input.join("\n")) do
      $mcb.run(["providers", "geocode", *arguments])
    end
  end

  let(:email) { "user@education.gov.uk" }
  let(:current_cycle) { find_or_create :recruitment_cycle }
  let(:next_cycle) { find_or_create :recruitment_cycle, :next }
  let(:organisation) { create(:organisation) }
  let(:first_provider) { create :provider, provider_name: "Z", updated_at: 1.day.ago, changed_at: 1.day.ago, recruitment_cycle: current_cycle }
  let(:second_provider) { create :provider, provider_name: "Y", updated_at: 1.day.ago, changed_at: 1.day.ago, recruitment_cycle: next_cycle }
  let(:default_sleep) { 0.25 }
  let!(:requester) { create(:user, email: email, organisations: [organisation]) }

  before do
    allow(MCB).to receive(:init_rails)
  end

  context "Geocoding all providers" do
    it "geocodes all Providers not currently geocoded" do
      expect(MCB).to receive(:geocode).with(obj: first_provider, sleep: default_sleep).and_call_original

      expect { execute_cmd }
        .to change { first_provider.reload.longitude }.from(nil).to(-0.1204749)
              .and change { first_provider.reload.latitude }.from(nil).to(51.4524877)
    end
  end

  context "Geocoding providers by provider code" do
    context "default recruitment cycle" do
      it "geocodes providers matching the default recruitment cycle" do
        expect(MCB).to receive(:geocode).with(obj: first_provider, sleep: default_sleep).and_call_original
        expect(MCB).to_not receive(:geocode).with(obj: second_provider, sleep: default_sleep)

        expect { execute_cmd(arguments: [first_provider.provider_code, second_provider.provider_code]) }
          .to change { first_provider.reload.latitude }.from(nil).to(51.4524877)
                .and change { first_provider.reload.longitude }.from(nil).to(-0.1204749)

        expect(second_provider.reload.latitude).to be(nil)
        expect(second_provider.reload.longitude).to be(nil)
      end
    end

    context "specific recruitment cycle" do
      it "geocodes providers matching the specified recruitment cycle" do
        expect(MCB).to receive(:geocode).with(obj: second_provider, sleep: default_sleep).and_call_original
        expect(MCB).to_not receive(:geocode).with(obj: first_provider, sleep: default_sleep)

        expect { execute_cmd(arguments: ["-r", next_cycle.year, second_provider.provider_code]) }
          .to change { second_provider.reload.latitude }.from(nil).to(51.4524877)
                .and change { second_provider.reload.longitude }.from(nil).to(-0.1204749)

        expect(first_provider.reload.latitude).to be(nil)
        expect(first_provider.reload.longitude).to be(nil)
      end
    end
  end
end
