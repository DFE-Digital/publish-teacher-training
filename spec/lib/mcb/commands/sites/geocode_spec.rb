require "mcb_helper"

describe "mcb geocode" do
  def execute_cmd(arguments: [], input: [])
    with_stubbed_stdout(stdin: input.join("\n")) do
      $mcb.run(["sites", "geocode", *arguments])
    end
  end

  let(:email) { "user@education.gov.uk" }
  let(:next_cycle) { find_or_create :recruitment_cycle, :next }
  let(:organisation) { create(:organisation) }
  let(:provider) { create :provider, provider_name: "Z", updated_at: 1.day.ago, changed_at: 1.day.ago, recruitment_cycle: next_cycle }
  let(:site_one) { create(:site, provider: provider) }
  let(:site_two) { create(:site, provider: provider) }


  before do
    allow(MCB).to receive(:init_rails)
  end

  context "Geocoding sites" do
    let!(:requester) { create(:user, email: email, organisations: [organisation]) }
    let(:default_sleep) { 0.25 }

    it "geocodes all Sites not currently geocoded" do
      expect(MCB).to receive(:geocode).with(obj: site_one, sleep: default_sleep, force: false).and_call_original

      expect { execute_cmd }
        .to change { site_one.reload.longitude }.from(nil).to(-0.1204749)
              .and change { site_one.reload.latitude }.from(nil).to(51.4524877)
    end

    it "geocodes Sites by id" do
      expect(MCB).to receive(:geocode).with(obj: site_two, sleep: default_sleep, force: false).and_call_original

      expect { execute_cmd(arguments: [site_two.id]) }
        .to change { site_two.reload.latitude }.from(nil).to(51.4524877)
              .and change { site_two.reload.longitude }.from(nil).to(-0.1204749)

      expect(site_one.reload.latitude).to be(nil)
      expect(site_one.reload.longitude).to be(nil)
    end

    context "invalid site" do
      let(:invalid_site) do
        invalid_site = build(:site, provider: provider, postcode: "this is not a postcode")
        invalid_site.save!(validate: false)
        invalid_site
      end

      it "geocodes all sites" do
        expect(MCB).to receive(:geocode).with(obj: invalid_site, sleep: default_sleep, force: true).and_call_original

        expect { execute_cmd(arguments: ["-f"]) }
          .to change { invalid_site.reload.latitude }.from(nil).to(51.4524877)
                .and change { invalid_site.reload.longitude }.from(nil).to(-0.1204749)
      end

      it "geocodes the site" do

        expect(MCB).to receive(:geocode).with(obj: invalid_site, sleep: default_sleep, force: true).and_call_original

        expect { execute_cmd(arguments: ["-f", invalid_site.id]) }
          .to change { invalid_site.reload.latitude }.from(nil).to(51.4524877)
                .and change { invalid_site.reload.longitude }.from(nil).to(-0.1204749)
      end
    end
  end
end
