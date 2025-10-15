# frozen_string_literal: true

require "rails_helper"

describe SendWelcomeEmailService do
  before { Timecop.freeze }

  after { Timecop.return }

  context "When the user has not logged in before" do
    let(:current_user_spy) do
      spy(
        first_name: "Meowington",
        email: "meowington@cat.net",
        first_login_date_utc: nil,
        welcome_email_date_utc: nil,
      )
    end

    before do
      allow(WelcomeEmailMailer).to receive_message_chain(:send_welcome_email, :deliver_later)
      described_class.call(current_user: current_user_spy)
    end

    it "sets their welcome email date to now" do
      expect(current_user_spy).to have_received(:update).with(hash_including(welcome_email_date_utc: Time.zone.now))
    end

    it "sends the welcome email" do
      expect(WelcomeEmailMailer).to have_received(:send_welcome_email)
    end

    it "sends the email to the user" do
      expect(WelcomeEmailMailer).to have_received(:send_welcome_email).with(hash_including(email: "meowington@cat.net"))
    end

    it "sends the users first name in the email" do
      expect(WelcomeEmailMailer).to have_received(:send_welcome_email).with(hash_including(first_name: "Meowington"))
    end
  end

  context "When the user has logged in before" do
    let(:current_user_spy) do
      spy(
        first_name: "Meowington",
        first_login_date_utc: Time.zone.local(2018, 1, 1),
        welcome_email_date_utc: Time.zone.local(2018, 1, 1),
      )
    end

    before do
      allow(WelcomeEmailMailer).to receive_message_chain(:send_welcome_email, :deliver_later)
      described_class.call(current_user: current_user_spy)
    end

    it "does not update their first login date" do
      expect(current_user_spy).not_to have_received(:update).with(hash_including(first_login_date_utc: Time.zone.now))
    end

    context "And has received a welcome email" do
      it "does not update their welcome email date" do
        expect(current_user_spy).not_to have_received(:update).with(hash_including(welcome_email_date_utc: Time.zone.now))
      end

      it "does not send the welcome email" do
        expect(WelcomeEmailMailer).not_to have_received(:send_welcome_email)
      end
    end

    context "And has not received a welcome email" do
      let(:current_user_spy) do
        spy(
          email: "meowington@cat.net",
          first_name: "Meowington",
          first_login_date_utc: Time.zone.local(2018, 1, 1),
          welcome_email_date_utc: nil,
        )
      end

      before do
        allow(WelcomeEmailMailer).to receive_message_chain(:send_welcome_email, :deliver_later)
      end

      it "sets their welcome email date to now" do
        expect(current_user_spy).to have_received(:update).with(hash_including(welcome_email_date_utc: Time.zone.now))
      end

      it "sends the welcome email" do
        expect(WelcomeEmailMailer).to have_received(:send_welcome_email)
      end

      it "sends the email to the user" do
        expect(WelcomeEmailMailer).to have_received(:send_welcome_email).with(hash_including(email: "meowington@cat.net"))
      end

      it "sends the users first name in the email" do
        expect(WelcomeEmailMailer).to have_received(:send_welcome_email).with(hash_including(first_name: "Meowington"))
      end
    end

    context "when the user does not have a first name" do
      let(:current_user_spy) do
        spy(
          email: "meowington@cat.net",
          first_name: nil,
          first_login_date_utc: Time.zone.local(2018, 1, 1),
          welcome_email_date_utc: nil,
        )
      end

      before do
        allow(WelcomeEmailMailer).to receive_message_chain(:send_welcome_email, :deliver_later)
        allow(Sentry).to receive(:capture_exception).with(SendWelcomeEmailService::MissingFirstNameError).and_return(nil)
      end

      it "does not set their welcome email date to now" do
        described_class.call(current_user: current_user_spy)
        expect(current_user_spy).not_to have_received(:update).with(hash_including(welcome_email_date_utc: Time.zone.now))
      end

      it "does not send the welcome email" do
        described_class.call(current_user: current_user_spy)
        expect(WelcomeEmailMailer).not_to have_received(:send_welcome_email)
      end

      it "sends the error to Sentry" do
        expect(Sentry).to receive(:capture_exception).with(SendWelcomeEmailService::MissingFirstNameError)
        described_class.call(current_user: current_user_spy)
      end
    end
  end
end
