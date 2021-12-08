require "rails_helper"

RSpec.describe UserAssociationsService::Delete do
  let(:user) { create :user }

  let(:accredited_body1) { create(:provider, :accredited_body, users: [user]) }
  # let(:organisation1) { create(:organisation, users: [user], providers: [accredited_body1]) }

  let(:accredited_body2) { create(:provider, :accredited_body, users: [user]) }
  # let(:organisation2) { create(:organisation, users: [user], providers: [accredited_body2]) }

  let(:user_notification1) do
    create(
      :user_notification,
      user: user,
      provider: accredited_body1,
      course_publish: true,
      course_update: true,
    )
  end

  let(:user_notification2) do
    create(
      :user_notification,
      user: user,
      provider: accredited_body2,
      course_publish: true,
      course_update: true,
    )
  end

  describe "#call" do
    context "when removing access to a single provider" do
      subject do
        described_class.call(
          user: user,
          providers: accredited_body1,
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
    end

    context "when removing access to multiple organsations" do
      subject do
        described_class.call(
          user: user,
          providers: [accredited_body1, accredited_body2],
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
          user: user,
          provider: accredited_body3,
          course_publish: true,
          course_update: true,
        )
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
