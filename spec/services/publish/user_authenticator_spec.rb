# frozen_string_literal: true

require "rails_helper"

module Publish
  describe UserAuthenticator do
    subject(:authenticator) { described_class.new(oauth:) }

    let(:oauth) do
      OmniAuth::AuthHash.new(
        "provider" => "dfe",
        "uid" => uid,
        "info" => {
          "email" => email,
          "first_name" => first_name,
          "last_name" => last_name,
        },
      )
    end

    let(:uid) { SecureRandom.uuid }
    let(:email) { "user@example.com" }
    let(:first_name) { "Jane" }
    let(:last_name) { "Smith" }

    context "when user has an existing authentication record" do
      let(:user) { create(:user) }
      let(:uid) { user.authentications.dfe_signin.first.subject_key }

      it "returns the user" do
        expect(authenticator.call).to eq(user)
      end

      it "does not create a new authentication record" do
        expect { authenticator.call }.not_to(change { user.authentications.count })
      end

      it "updates last_login_date_utc" do
        freeze_time do
          authenticator.call
          expect(user.reload.last_login_date_utc).to eq(Time.zone.now)
        end
      end

      context "when email has changed in DfE Sign-In" do
        let(:email) { "new-email@example.com" }

        it "updates the email" do
          authenticator.call
          expect(user.reload.email).to eq("new-email@example.com")
        end
      end

      it "finds the user even if their email has changed" do
        user.update!(email: "old-email@example.com")
        expect(authenticator.call).to eq(user)
      end
    end

    context "when user exists by email but has no authentication record" do
      let!(:user) { create(:user, :without_dfe_signin, email:) }

      it "returns the user" do
        expect(authenticator.call).to eq(user)
      end

      it "creates an authentication record" do
        expect { authenticator.call }.to change { user.authentications.dfe_signin.count }.by(1)
      end

      it "stores the correct subject_key" do
        authenticator.call
        expect(user.authentications.dfe_signin.first.subject_key).to eq(uid)
      end

      context "when updating user details fails" do
        before do
          allow(User).to receive(:find_by).with(email:).and_return(user)
          allow(user).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)
        end

        it "does not create an authentication record" do
          expect { authenticator.call }.to raise_error(ActiveRecord::RecordInvalid)
            .and(not_change { user.authentications.count })
        end
      end
    end

    context "when no user exists" do
      it "returns nil" do
        expect(authenticator.call).to be_nil
      end

      it "does not create an authentication record" do
        expect { authenticator.call }.not_to change(::Authentication, :count)
      end
    end
  end
end
