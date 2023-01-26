# frozen_string_literal: true

require "rails_helper"

describe AuthenticationService do
  describe "#execute" do
    let(:user) { create(:user) }
    let(:email) { user.email }
    let(:first_name) { user.first_name }
    let(:last_name) { user.last_name }
    let(:sign_in_user_id) { user.sign_in_user_id }
    let(:logger_spy) { spy }
    let(:payload) do
      {
        email:,
        sign_in_user_id:,
        first_name:,
        last_name:,
      }
    end
    let(:token) { build_jwt(:apiv2, payload:) }

    let(:service) { described_class.new(logger: logger_spy) }

    subject { service.execute(token) }

    context "with a valid DfE-SignIn ID and email" do
      let(:first_name) { "#{user.first_name}_new" }
      let(:last_name) { "#{user.last_name}_new" }

      it { is_expected.to eq user }

      it "Sets the users first name" do
        expect { subject }.to(change { user.reload.first_name }.to(first_name))
      end

      it "Sets the users last name" do
        expect { subject }.to(change { user.reload.last_name }.to(last_name))
      end

      it "Safely logs that the user was found by sign_in_user_id" do
        subject

        expect(logger_spy).to have_received(:info) do |*_args, &block|
          message = block.call
          expect(message).to start_with("User found from sign_in_user_id in token")
          expect(message).to include("sign_in_user_id=>\"#{sign_in_user_id}\"")
          expect(message).not_to include(user.email)
        end
      end
    end

    context "with a valid DfE-SignIn ID but invalid email" do
      let(:email) { "bob@gmail.com" }

      it { is_expected.to eq user }

      it "update's the user's email" do
        expect { subject }.to(change { user.reload.email }.to(email))
      end

      it "logs that the users email was updated" do
        subject

        expect(logger_spy).to have_received(:debug) do |*_args, &block|
          message = block.call
          expect(message).to start_with("Updating user email for")
        end
      end

      context "when the email is already in use" do
        let!(:existing_user) { create(:user, email:) }

        it { is_expected.to eq user }

        it "updates the user's email" do
          expect { subject }.to(change { user.reload.email }.to(email))
        end

        Timecop.freeze do # TODO: possible race condition here
          it "updates the existing users email to example email" do
            expect { subject }.to(change { existing_user.reload.email }.to("bob_#{Time.now.to_i}_gmail.com@example.com"))
          end
        end
      end
    end

    context "with a valid email but invalid DfE-SignIn ID" do
      let(:sign_in_user_id) { SecureRandom.uuid }

      it { is_expected.to eq user }

      it "update's the user's SignIn ID" do
        expect { subject }.to(change { user.reload.sign_in_user_id }.to(sign_in_user_id))
      end

      it "Safely logs that the user was found by their email" do
        subject

        expect(logger_spy).to have_received(:info) do |*_args, &block|
          message = block.call
          expect(message).to start_with("User found by email address")
          expect(message).not_to include(user.email)
        end
      end
    end

    context "with a valid email but nil DfE-SignIn ID" do
      let(:user) { create(:user, sign_in_user_id: nil) }
      let(:sign_in_user_id) { SecureRandom.uuid }

      it { is_expected.to eq user }

      it "update's the user's SignIn ID" do
        expect { subject }.to(change { user.reload.sign_in_user_id }.to(sign_in_user_id))
      end
    end

    context "with a valid email but an invalid DfE-SignIn ID" do
      let(:sign_in_user_id) { SecureRandom.uuid }

      it { is_expected.to eq user }
    end

    context "with an email that has different case from the database" do
      let(:email) { user.email.upcase }

      before do
        user.update(email: user.email.capitalize)
      end

      it { is_expected.to eq user }
    end

    context "when the email is an empty string" do
      let(:email) { "" }
      let(:sign_in_user_id) { SecureRandom.uuid }

      before do
        user.update_attribute(:email, "")
      end

      it "does not authenticate the user based on an empty string match" do
        expect(subject).not_to eq user
      end

      it "Logs that there was no email in the token" do
        subject

        expect(logger_spy).to have_received(:debug) do |*_args, &block|
          message = block.call
          expect(message).to start_with("No email in token")
        end
      end
    end

    context "when the sign_in_user_id is nil" do
      let!(:user) { create(:user, sign_in_user_id: nil) }
      let(:email) { Faker::Internet.email }
      let(:sign_in_user_id) { nil }

      it "does not authenticate the user based on a nil match" do
        expect(subject).not_to eq user
      end

      it "Logs that there was no signin user id in the token" do
        subject

        expect(logger_spy).to have_received(:debug) do |*_args, &block|
          message = block.call
          expect(message).to start_with("No sign_in_user_id in token")
        end
      end
    end

    context "When the first name is nil" do
      let(:first_name) { nil }

      it "does not set the first name to nil" do
        expect { subject }.not_to(change { user.reload.first_name })
      end
    end

    context "When the last name is nil" do
      let(:last_name) { nil }

      it "does not set the last name to nil" do
        expect { subject }.not_to(change { user.reload.last_name })
      end
    end
  end
end
