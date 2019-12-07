require "mcb_helper"

describe "mcb providers geocode" do
  def execute_cmd(arguments: [], input: [])
    with_stubbed_stdout(stdin: input.join("\n")) do
      $mcb.run(["providers", "geocode", *arguments])
    end
  end

  let(:email) { "user@education.gov.uk" }
  let(:next_cycle) { find_or_create :recruitment_cycle, :next }
  let(:organisation) { create(:organisation) }
  let(:provider) { create :provider, provider_name: "Z", updated_at: 1.day.ago, changed_at: 1.day.ago, recruitment_cycle: next_cycle }
  let(:second_provider) { create :provider, id: 2, provider_name: "Z", updated_at: 1.day.ago, changed_at: 1.day.ago, recruitment_cycle: next_cycle }

  before do
    allow(MCB).to receive(:config).and_return(email: email)
  end

  context "Geocoding providers" do
    let!(:requester) { create(:user, email: email, organisations: [organisation]) }

    it "geocodes all Providers not currently geocoded" do
      expect { execute_cmd }
        .to change { provider.reload.longitude }.from(nil).to(-0.1204749)
              .and change { provider.reload.latitude }.from(nil).to(51.4524877)
    end

    it "geocodes Providers by id" do
      expect { execute_cmd(arguments: [second_provider.id]) }
        .to change { second_provider.reload.latitude }.from(nil).to(51.4524877)
              .and change { second_provider.reload.longitude }.from(nil).to(-0.1204749)

      expect(provider.reload.latitude).to be(nil)
      expect(provider.reload.longitude).to be(nil)
    end

    it "raises and error when it can find a provider" do
      unknown_id = 123
      expect { execute_cmd(arguments: [unknown_id]) }.
        to raise_error(ActiveRecord::RecordNotFound, /Couldn't find Provider/)
    end
  end
end
