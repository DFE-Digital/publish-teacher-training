require "rails_helper"

RSpec.describe UserAssociationsService::Create do
  let(:user) { create :user }
  let(:accredited_body) { create(:provider, :accredited_body) }
  let(:organisation) { create(:organisation, users: [user], providers: [accredited_body]) }

  let(:new_accredited_body) { create(:provider, :accredited_body) }
  let(:new_organisation) { create(:organisation, providers: [new_accredited_body]) }

  subject do
    described_class.call(
      organisation: new_organisation,
      user: user,
    )
  end

  describe "#call" do
    context "when user have saved notification prefernces" do
      let(:user_notification) do
        create(
          :user_notification,
          user: user,
          provider: accredited_body,
          course_publish: true,
          course_update: true,
        )
      end

      let(:new_user_notification) do
        create(
          :user_notification,
          user: user,
          provider: new_accredited_body,
          course_publish: true,
          course_update: true,
        )
      end

      before do
        organisation
        user_notification
      end

      it "creates organisation_users association" do
        subject

        expect(new_organisation.users).to eq([user])
        expect(user.organisations).to include(organisation, new_organisation)
      end

      it "creates user_notifications association with the previous enabled value" do
        subject

        expect(UserNotification.where(user_id: user.id).count).to eq(2)
        expect(UserNotification.where(user_id: user.id)).to include(new_user_notification)
      end
    end

    context "when user has never set notification prefernces" do
      before do
        organisation
      end

      it "creates organisation_users association" do
        subject

        expect(new_organisation.users).to eq([user])
        expect(user.organisations).to include(organisation, new_organisation)
      end

      it "doesn't create user_notifications association" do
        subject

        expect(UserNotification.where(user_id: user.id).count).to eq(0)
      end
    end
  end
end
