# frozen_string_literal: true

require "rails_helper"

RSpec.describe APIKey do
  let(:email) { "api-user@example.org" }

  describe ".find_active_by_secret" do
    let(:api_key) { create(:api_key) }

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
    let(:api_key) { create(:api_key) }

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
      keys = create_list(:api_key, described_class::MAXIMUM_ACTIVE, email:)
      keys.first.revoke!

      expect(build(:api_key, email:)).to be_valid
    end
  end

  describe "validations" do
    it "tells the user to enter a name" do
      api_key = build(:api_key, name: "")

      expect(api_key).not_to be_valid
      expect(api_key.errors[:name]).to eq(["Enter a name for your API key"])
    end

    it "tells the user to enter an email address" do
      api_key = build(:api_key, email: " ")

      expect(api_key).not_to be_valid
      expect(api_key.errors[:email]).to eq(["Enter an email address"])
    end

    it "tells the user to correct a malformed email address" do
      api_key = build(:api_key, email: "not an email")

      expect(api_key).not_to be_valid
      expect(api_key.errors[:email]).to eq(["Enter an email address in the correct format, like name@example.com"])
    end

    it "rejects a key beyond the active limit" do
      create_list(:api_key, described_class::MAXIMUM_ACTIVE, email:)
      api_key = build(:api_key, email:)

      expect(api_key).not_to be_valid
      expect(api_key.errors[:base]).to eq(["You can only have 5 active API keys. Revoke a key before creating another"])
    end

    it "counts only the same email's keys towards the active limit" do
      create_list(:api_key, described_class::MAXIMUM_ACTIVE, email: "other@example.org")

      expect(build(:api_key, email:)).to be_valid
    end

    it "lets an existing key be updated at the active limit" do
      keys = create_list(:api_key, described_class::MAXIMUM_ACTIVE, email:)

      expect(keys.first.update(name: "Renamed")).to be(true)
    end
  end

  it "stores the email stripped and in lower case" do
    expect(create(:api_key, email: " API-User@Example.org ").reload.email).to eq(email)
  end

  it "cannot have its email changed once created" do
    api_key = create(:api_key, email:)

    expect { api_key.update(email: "other@example.org") }.to raise_error(ActiveRecord::ReadonlyAttributeError)
  end

  describe ".lock_email" do
    it "keeps the email out of the SQL it runs" do
      statements = []

      ActiveSupport::Notifications.subscribed(->(*, payload) { statements << payload[:sql] }, "sql.active_record") do
        described_class.transaction { described_class.lock_email(email) }
      end

      expect(statements.join).to include("pg_advisory_xact_lock")
      expect(statements.join).not_to include(email)
    end

    it "takes the same lock however the email is written" do
      statements = []

      ActiveSupport::Notifications.subscribed(->(*, payload) { statements << payload[:sql] }, "sql.active_record") do
        described_class.transaction do
          described_class.lock_email(email)
          described_class.lock_email(" #{email.upcase} ")
        end
      end

      expect(statements.grep(/pg_advisory_xact_lock/).uniq.size).to eq(1)
    end
  end

  it "keeps a key updatable after its email is moved to one the validator would refuse" do
    api_key = create(:api_key, email:)
    described_class.where(id: api_key.id).update_all(email: "a@b")

    expect(api_key.reload.update(name: "Renamed")).to be(true)
  end

  describe "auditing" do
    let(:user) { create(:user, email:) }

    it "records creation against a user holding the email, with only the prefix and revocation" do
      user
      api_key = create(:api_key, email:)

      expect(user.associated_audits.sole).to have_attributes(
        auditable: api_key,
        audited_changes: { "prefix" => api_key.prefix, "revoked_at" => nil },
      )
    end

    it "records creation against no one when no user holds the email" do
      api_key = create(:api_key, email:)

      expect(api_key.audits.sole).to have_attributes(associated: nil, action: "create")
    end

    it "records revocation" do
      api_key = create(:api_key)

      expect { api_key.revoke! }.to change { api_key.audits.count }.by(1)
      expect(api_key.audits.last.audited_changes.keys).to eq(%w[revoked_at])
    end
  end

  describe "#inspect" do
    it "masks the email, the digest and the name" do
      expect(create(:api_key).inspect).to include("email: [FILTERED]", "key_digest: [FILTERED]", "name: [FILTERED]")
    end
  end

  describe "#user" do
    it "is nil when no user holds the email" do
      expect(create(:api_key, email:).user).to be_nil
    end
  end

  it "follows the user holding its email when that email changes" do
    user = create(:user, email:)
    api_key = create(:api_key, email:)

    user.update!(email: "changed@example.org")

    expect(user.api_keys.reload).to contain_exactly(api_key)
    expect(api_key.reload.email).to eq("changed@example.org")
  end

  it "is removed when the user holding its email is destroyed" do
    user = create(:user, email:)
    api_key = create(:api_key, email:)

    user.destroy!

    expect(described_class.exists?(api_key.id)).to be(false)
  end
end
