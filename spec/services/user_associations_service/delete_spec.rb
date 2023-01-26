require "rails_helper"

RSpec.describe UserAssociationsService::Delete, { can_edit_current_and_next_cycles: false } do
  let(:user) { create(:user) }

  let(:accredited_body1) { create(:provider, :accredited_body, users: [user]) }

  let(:accredited_body2) { create(:provider, :accredited_body, users: [user]) }

  let(:user_notification1) do
    create(
      :user_notification,
      user:,
      provider: accredited_body1,
      course_publish: true,
      course_update: true
    )
  end

  let(:user_notification2) do
    create(
      :user_notification,
      user:,
      provider: accredited_body2,
      course_publish: true,
      course_update: true
    )
  end

  let(:action_mailer) { double }

  before do
    allow(RemoveUserFromOrganisationMailer).to receive(:remove_user_from_provider_email).and_return(action_mailer)
    allow(action_mailer).to receive(:deliver_later)
  end

  describe "#call" do
    context "when removing access to a single provider" do
      subject do
        described_class.call(
          user:,
          providers: accredited_body1
        )
      end

      before do
        accredited_body1
        accredited_body2
      end

      context "when user have saved notification preferences" do
        before do
          user_notification1
          user_notification2
        end

        it "sends the email to the user" do
          subject
          expect(RemoveUserFromOrganisationMailer).to have_received(:remove_user_from_provider_email).with(hash_including(recipient: user, provider: accredited_body1))
          expect(action_mailer).to have_received(:deliver_later)
        end

        it "removes user_permissions association" do
          subject

          accredited_body1.reload
          expect(accredited_body1.users).not_to include(user)
          expect(user.providers).not_to include(accredited_body1)
        end

        it "removes user_notifications association for providers within the provider" do
          subject

          expect(UserNotification.where(user_id: user.id).count).to eq(1)
          expect(UserNotification.where(user_id: user.id)).not_to include(user_notification1)
        end
      end

      context "when user has never set notification preferences" do
        it "removes organisation_users association" do
          subject

          accredited_body1.reload
          expect(accredited_body1.users).not_to include(user)
          expect(user.providers).not_to include(accredited_body1)
        end

        it "doesn't update user_notifications association" do
          subject

          expect(UserNotification.where(user_id: user.id).count).to eq(0)
        end
      end

      context "during rollover", { can_edit_current_and_next_cycles: true } do
        let(:next_accredited_body1) { create(:provider, :accredited_body, :next_recruitment_cycle, provider_code: "AAA") }

        it "removes user_permissions association in both cycles" do
          subject
          accredited_body1.reload
          expect(accredited_body1.users).not_to include(user)
          expect(next_accredited_body1.users).not_to include(user)
          expect(user.providers).not_to include(accredited_body1)
          expect(user.providers).not_to include(next_accredited_body1)
        end
      end
    end

    context "when removing access to multiple organsations" do
      subject do
        described_class.call(
          user:,
          providers: [accredited_body1, accredited_body2]
        )
      end

      before do
        accredited_body1
        accredited_body2
      end

      let(:accredited_body3) { create(:provider, :accredited_body, users: [user]) }

      let(:user_notification3) do
        create(
          :user_notification,
          user:,
          provider: accredited_body3,
          course_publish: true,
          course_update: true
        )
      end

      it "sends the emails to the user" do
        subject
        expect(RemoveUserFromOrganisationMailer).to have_received(:remove_user_from_provider_email).with(hash_including(recipient: user, provider: accredited_body1))
        expect(RemoveUserFromOrganisationMailer).to have_received(:remove_user_from_provider_email).with(hash_including(recipient: user, provider: accredited_body2))
        expect(action_mailer).to have_received(:deliver_later).twice
      end

      context "when user have saved notification preferences" do
        before do
          accredited_body3

          user_notification1
          user_notification2
          user_notification3
        end

        it "removes user_permissions associations" do
          subject

          expect(user.providers).not_to include(accredited_body1, accredited_body2)
          accredited_body1.reload
          expect(accredited_body1.users).not_to include(user)
          accredited_body2.reload
          expect(accredited_body2.users).not_to include(user)
        end

        it "removes user_notifications only for providers within the removed organisations" do
          subject

          expect(UserNotification.where(user_id: user.id).count).to eq(1)
          expect(UserNotification.where(user_id: user.id).first.provider_code)
            .to eq(accredited_body3.provider_code)
        end
      end
    end
  end
end
