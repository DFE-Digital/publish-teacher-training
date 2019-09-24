describe SendWelcomeEmailService do
  let(:mailer_spy) { spy }
  let(:service) { SendWelcomeEmailService.new(mailer: mailer_spy) }

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

    before { service.execute(current_user: current_user_spy) }

    it "sets their first login date to now" do
      expect(current_user_spy).to have_received(:update).with(hash_including(first_login_date_utc: Time.now.utc))
    end

    it "sets their welcome email date to now" do
      expect(current_user_spy).to have_received(:update).with(hash_including(welcome_email_date_utc: Time.now.utc))
    end

    it "sends the welcome email" do
      expect(mailer_spy).to have_received(:send_welcome_email)
    end

    it "sends the email to the user" do
      expect(mailer_spy).to have_received(:send_welcome_email).with(hash_including(email: "meowington@cat.net"))
    end

    it "sends the users first name in the email" do
      expect(mailer_spy).to have_received(:send_welcome_email).with(hash_including(first_name: "Meowington"))
    end
  end

  context "When the user has logged in before" do
    let(:current_user_spy) do
      spy(
        first_name: "Meowington",
        first_login_date_utc: Time.local(2018, 1, 1).utc,
        welcome_email_date_utc: Time.local(2018, 1, 1).utc,
      )
    end

    before { service.execute(current_user: current_user_spy) }

    it "does not update their first login date" do
      expect(current_user_spy).not_to have_received(:update).with(hash_including(first_login_date_utc: Time.now.utc))
    end

    context "And has received a welcome email" do
      it "does not update their welcome email date" do
        expect(current_user_spy).not_to have_received(:update).with(hash_including(welcome_email_date_utc: Time.now.utc))
      end

      it "does not send the welcome email" do
        expect(mailer_spy).not_to have_received(:send_welcome_email)
      end
    end

    context "And has not received a welcome email" do
      let(:current_user_spy) do
        spy(
          email: "meowington@cat.net",
          first_name: "Meowington",
          first_login_date_utc: Time.local(2018, 1, 1).utc,
          welcome_email_date_utc: nil,
        )
      end

      it "sets their welcome email date to now" do
        expect(current_user_spy).to have_received(:update).with(hash_including(welcome_email_date_utc: Time.now.utc))
      end

      it "sends the welcome email" do
        expect(mailer_spy).to have_received(:send_welcome_email)
      end

      it "sends the email to the user" do
        expect(mailer_spy).to have_received(:send_welcome_email).with(hash_including(email: "meowington@cat.net"))
      end

      it "sends the users first name in the email" do
        expect(mailer_spy).to have_received(:send_welcome_email).with(hash_including(first_name: "Meowington"))
      end
    end
  end
end
