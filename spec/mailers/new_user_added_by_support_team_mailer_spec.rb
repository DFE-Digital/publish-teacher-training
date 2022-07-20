require "rails_helper"

describe NewUserAddedBySupportTeamMailer, type: :mailer do
  context "Sending an email to a user" do
    let(:user) { create :user }

    let(:mail) { described_class.user_added_to_provider_email(recipient: user) }

    before { mail }

    it "Sends an email with the correct template" do
      expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.new_user_added_by_support_team_id)
    end

    it "Sends an email to the correct email address" do
      expect(mail.to).to eq([user.email])
    end
  end
end
