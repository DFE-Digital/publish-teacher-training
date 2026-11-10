# frozen_string_literal: true

require "rails_helper"

RSpec.describe APIKeys::Creator do
  let(:email) { "api-user@example.org" }
  let(:moved_email) { "moved@example.org" }

  it "returns the secret once and stores only its digest" do
    api_key = described_class.call(email:, name: "Reporting")
    secret = api_key.secret

    expect(secret).to match(/\Aptt_\h{64}\z/)
    expect(APIKey.find(api_key.id)).to have_attributes(
      email:,
      name: "Reporting",
      key_digest: Digest::SHA256.hexdigest(secret),
      prefix: secret.first(12),
      last_used_at: nil,
      revoked_at: nil,
    )
  end

  it "returns an unsaved key with errors and no secret when invalid" do
    api_key = described_class.call(email:, name: "")

    expect(api_key).not_to be_persisted
    expect(api_key.errors).to be_of_kind(:name, :blank)
    expect(api_key.secret).to be_nil
  end

  describe "concurrent creation", :commits_data, :no_default_recycle do
    self.use_transactional_tests = false

    after do
      APIKey.where(email: [email, moved_email]).delete_all
      User.where(email: [email, moved_email]).delete_all
      Audited.audit_class.delete_all
    end

    it "takes the email lock before the user row when an email changes, so it cannot deadlock with a destroy" do
      user = create(:user, email:)
      edit = nil

      APIKey.transaction do
        APIKey.lock_email(email)
        edit = Thread.new do
          ActiveRecord::Base.connection_pool.with_connection { User.find(user.id).update!(email: moved_email) }
        end
        sleep 0.2

        expect { User.lock("FOR UPDATE NOWAIT").find(user.id) }.not_to raise_error
      end

      edit.value
    end

    it "leaves no key behind when the user holding the email is destroyed during creation" do
      user = create(:user, email:)
      locked = Concurrent::Event.new

      creation = Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          APIKey.transaction do
            APIKey.lock_email(email)
            locked.set
            sleep 0.2
            create(:api_key, email:)
          end
        end
      end

      expect(locked.wait(10)).to be(true)
      user.destroy!
      creation.value

      expect(APIKey.where(email:)).to be_empty
    end

    it "holds the active limit when creations race, whatever case the email arrives in" do
      create_list(:api_key, APIKey::MAXIMUM_ACTIVE - 1, email:)
      barrier = Concurrent::CyclicBarrier.new(3)

      [email, email.upcase, " #{email} "].map { |racing_email|
        Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do
            barrier.wait(10)
            described_class.call(email: racing_email, name: "Racer")
          end
        end
      }.each(&:value)

      expect(APIKey.active.where(email:).count).to eq(APIKey::MAXIMUM_ACTIVE)
    end

    it "creates one key when the same submission races" do
      submission_token = SecureRandom.uuid
      barrier = Concurrent::CyclicBarrier.new(2)

      api_keys = Array.new(2) {
        Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do
            barrier.wait(10)
            described_class.call(email:, name: "Racer", submission_token:)
          end
        end
      }.map(&:value)

      expect(api_keys.count(&:persisted?)).to eq(1)
      expect(api_keys.reject(&:persisted?).sole.errors).to be_of_kind(:submission_token, :taken)
    end
  end
end
