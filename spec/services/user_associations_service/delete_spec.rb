require "rails_helper"

RSpec.describe UserAssociationsService::Delete do
  let(:user) { create :user }

  let(:accredited_body1) { create(:provider, :accredited_body) }
  let(:organisation1) { create(:organisation, users: [user], providers: [accredited_body1]) }

  let(:accredited_body2) { create(:provider, :accredited_body) }
  let(:organisation2) { create(:organisation, users: [user], providers: [accredited_body2]) }

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
    context "when removing access to a single organsation" do
      subject do
        described_class.call(
          user: user,
          organisations: organisation1,
        )
      end

      before do
        organisation1
        organisation2
      end

      context "when user have saved notification preferences" do
        before do
          user_notification1
          user_notification2
        end

        it "removes organisation_users association" do
          subject

          organisation1.reload
          expect(organisation1.users).not_to include(user)
          expect(user.organisations).not_to include(organisation1)
        end

        it "removes user_notifications association for providers within the organisation" do
          subject

          expect(UserNotification.where(user_id: user.id).count).to eq(1)
          expect(UserNotification.where(user_id: user.id)).not_to include(user_notification1)
        end
      end

      context "when user has never set notification preferences" do
        it "removes organisation_users association" do
          subject

          organisation1.reload
          expect(organisation1.users).not_to include(user)
          expect(user.organisations).not_to include(organisation1)
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
          organisations: [organisation1, organisation2],
        )
      end

      before do
        organisation1
        organisation2
      end

      let(:accredited_body3) { create(:provider, :accredited_body) }
      let(:organisation3) { create(:organisation, users: [user], providers: [accredited_body3]) }

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
          organisation3

          user_notification1
          user_notification2
          user_notification3
        end

        it "removes organisation_users associations" do
          subject

          expect(user.organisations).not_to include(organisation1, organisation2)
          organisation1.reload
          expect(organisation1.users).not_to include(user)
          organisation2.reload
          expect(organisation2.users).not_to include(user)
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
