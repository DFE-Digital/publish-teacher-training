# frozen_string_literal: true

require "rails_helper"

RSpec.describe APIKey do
  let(:user) { create(:user) }

  describe ".find_active_by_secret" do
    let(:api_key) { create(:api_key, user:) }

    it "finds an active key" do
      expect(described_class.find_active_by_secret(api_key.secret)).to eq(api_key)
    end

    it "returns nil for a revoked key" do
      secret = api_key.secret
      api_key.revoke!

      expect(described_class.find_active_by_secret(secret)).to be_nil
    end

    it "returns nil for an unknown secret" do
      api_key

      expect(described_class.find_active_by_secret("ptt_unknown")).to be_nil
    end

    it "returns nil for a nil secret" do
      api_key

      expect(described_class.find_active_by_secret(nil)).to be_nil
    end
  end

  describe "#revoke!" do
    let(:api_key) { create(:api_key, user:) }

    it "does not move revoked_at on a second call" do
      revoked_at = 1.day.ago.round
      api_key.update!(revoked_at:)

      api_key.revoke!

      expect(api_key.reload.revoked_at).to eq(revoked_at)
    end

    it "revokes without validating or saving unsaved changes" do
      saved_name = api_key.name
      api_key.name = ""

      api_key.revoke!

      expect(described_class.find(api_key.id)).to have_attributes(name: saved_name, revoked_at: be_present)
    end

    it "frees a slot under the active limit" do
      keys = create_list(:api_key, described_class::MAXIMUM_ACTIVE, user:)
      keys.first.revoke!

      expect(build(:api_key, user:)).to be_valid
    end
  end

  describe "validations" do
    it "tells the user to enter a name" do
      api_key = build(:api_key, user:, name: "")

      expect(api_key).not_to be_valid
      expect(api_key.errors[:name]).to eq(["Enter a name for your API key"])
    end

    it "rejects a key beyond the active limit" do
      create_list(:api_key, described_class::MAXIMUM_ACTIVE, user:)
      api_key = build(:api_key, user:)

      expect(api_key).not_to be_valid
      expect(api_key.errors[:base]).to eq(["You can only have 5 active API keys. Revoke a key before creating another"])
    end

    it "counts only the user's own keys towards the active limit" do
      create_list(:api_key, described_class::MAXIMUM_ACTIVE, user: create(:user))

      expect(build(:api_key, user:)).to be_valid
    end

    it "lets an existing key be updated at the active limit" do
      keys = create_list(:api_key, described_class::MAXIMUM_ACTIVE, user:)

      expect(keys.first.update(name: "Renamed")).to be(true)
    end
  end

  describe "auditing" do
    it "records creation against the user with only the prefix and revocation" do
      api_key = create(:api_key, user:)

      expect(user.associated_audits.sole).to have_attributes(
        auditable: api_key,
        audited_changes: { "prefix" => api_key.prefix, "revoked_at" => nil },
      )
    end

    it "records revocation" do
      api_key = create(:api_key, user:)

      expect { api_key.revoke! }.to change { api_key.audits.count }.by(1)
      expect(api_key.audits.last.audited_changes.keys).to eq(%w[revoked_at])
    end
  end

  describe "#inspect" do
    it "masks the email, the digest and the name" do
      expect(create(:api_key, user:).inspect).to include("email: [FILTERED]", "key_digest: [FILTERED]", "name: [FILTERED]")
    end
  end

  it "stays with its user when the user's email changes" do
    api_key = create(:api_key, user:)

    user.update!(email: "changed@example.org")

    expect(user.api_keys.reload).to contain_exactly(api_key)
    expect(api_key.reload.email).to eq("changed@example.org")
  end

  it "is removed by the database when its user is deleted" do
    api_key = create(:api_key, user:)

    user.delete

    expect(described_class.exists?(api_key.id)).to be(false)
  end
end
