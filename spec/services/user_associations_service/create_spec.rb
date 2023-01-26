# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserAssociationsService::Create, { can_edit_current_and_next_cycles: false } do
  let(:user) { create(:user) }

  describe "#call" do
    context "when adding to a single organisation" do
      let(:accredited_body) { create(:provider, :accredited_body, users: [user]) }

      let(:new_accredited_body) { create(:provider, :accredited_body, provider_code: "AAA") }

      let(:action_mailer) { double }

      subject do
        described_class.call(
          provider: new_accredited_body,
          user:
        )
      end

      before do
        allow(NewUserAddedBySupportTeamMailer).to receive(:user_added_to_provider_email).and_return(action_mailer)
        allow(action_mailer).to receive(:deliver_later)
      end

      it "sends the email to the user" do
        subject
        expect(NewUserAddedBySupportTeamMailer).to have_received(:user_added_to_provider_email).with(hash_including(recipient: user))
        expect(action_mailer).to have_received(:deliver_later)
      end

      context "when user have saved notification preferences" do
        let(:user_notification) do
          create(
            :user_notification,
            user:,
            provider: accredited_body,
            course_publish: true,
            course_update: true
          )
        end

        let(:new_user_notification) do
          create(
            :user_notification,
            user:,
            provider: new_accredited_body,
            course_publish: true,
            course_update: true
          )
        end

        before do
          user_notification
        end

        it "creates user_permissions association" do
          subject

          expect(new_accredited_body.users).to eq([user])
          expect(user.providers).to include(accredited_body, new_accredited_body)
        end

        it "creates user_notifications association with the previous enabled value" do
          subject

          expect(UserNotification.where(user_id: user.id).count).to eq(2)
          expect(UserNotification.where(user_id: user.id)).to include(new_user_notification)
        end
      end

      context "when user has never set notification preferences" do
        it "creates user_permissions association" do
          subject

          expect(new_accredited_body.users).to eq([user])
          expect(user.providers).to include(accredited_body, new_accredited_body)
        end

        it "doesn't create user_notifications association" do
          subject

          expect(UserNotification.where(user_id: user.id).count).to eq(0)
        end
      end
    end

    context "when adding to all providers" do
      subject do
        described_class.call(
          user:,
          all_providers: true
        )
      end

      let(:accredited_body) { create(:provider, :accredited_body) }
      let!(:provider1) { create(:provider, :accredited_body) }

      context "when user have saved notification preferences" do
        let(:user_notification) do
          create(
            :user_notification,
            user:,
            provider: accredited_body,
            course_publish: true,
            course_update: true
          )
        end

        before do
          user_notification
        end

        it "creates user_permissions association" do
          subject

          expect(user.providers).to match_array(Provider.all)
        end

        it "creates user_notifications association for all user's accredited bodies" do
          subject

          expect(UserNotification.where(user_id: user.id).count).to eq(2)
        end
      end

      context "when user has never set notification preferences" do
        it "creates user_permissions association" do
          subject

          expect(user.providers).to match_array(Provider.all)
        end

        it "doesn't create user_notifications association" do
          subject

          expect(UserNotification.where(user_id: user.id).count).to eq(0)
        end
      end
    end
  end
end
