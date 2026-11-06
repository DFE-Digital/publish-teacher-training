# frozen_string_literal: true

require "rails_helper"

RSpec.describe APIKeys::Creator do
  let(:user) { create(:user) }

  it "returns the secret once and stores only its digest" do
    api_key = described_class.call(user:, name: "Reporting")
    secret = api_key.secret

    expect(secret).to match(/\Aptt_\h{64}\z/)
    expect(APIKey.find(api_key.id)).to have_attributes(
      email: user.email,
      name: "Reporting",
      key_digest: Digest::SHA256.hexdigest(secret),
      prefix: secret.first(12),
      last_used_at: nil,
      revoked_at: nil,
    )
  end

  it "returns an unsaved key with errors and no secret when invalid" do
    api_key = described_class.call(user:, name: "")

    expect(api_key).not_to be_persisted
    expect(api_key.errors).to be_of_kind(:name, :blank)
    expect(api_key.secret).to be_nil
  end

  it "leaves a rejected key off the user" do
    described_class.call(user:, name: "")

    expect(user.api_keys).to be_empty
    expect(user).to be_valid
  end

  it "creates a key under the saved email of a user with unsaved changes and keeps those changes" do
    saved_email = user.email
    user.email = "unsaved@example.org"

    expect(described_class.call(user:, name: "Reporting")).to have_attributes(persisted?: true, email: saved_email)
    expect(user.email).to eq("unsaved@example.org")
  end

  it "creates the key for the user behind a stale record, not whoever now holds its old email" do
    stale_user = User.find(user.id)
    old_email = user.email
    user.update!(email: "moved@example.org")
    new_holder = create(:user, email: old_email)

    expect(described_class.call(user: stale_user, name: "Reporting")).to have_attributes(user:, email: "moved@example.org")
    expect(new_holder.api_keys).to be_empty
  end

  describe "concurrent creation", :commits_data, :no_default_recycle do
    self.use_transactional_tests = false

    after do
      user.destroy!
      Audited.audit_class.where(auditable: user).or(Audited.audit_class.where(associated: user)).delete_all
    end

    it "holds the active limit when creations race" do
      create_list(:api_key, APIKey::MAXIMUM_ACTIVE - 1, user:)
      barrier = Concurrent::CyclicBarrier.new(3)

      Array.new(3) { |n|
        Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do
            racing_user = User.find(user.id)
            barrier.wait(10)
            described_class.call(user: racing_user, name: "Racer #{n}")
          end
        end
      }.each(&:value)

      expect(user.api_keys.active.count).to eq(APIKey::MAXIMUM_ACTIVE)
    end
  end
end
