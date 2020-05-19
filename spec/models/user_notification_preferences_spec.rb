require "rails_helper"

describe UserNotificationPreferences do
  describe "#enabled" do
    let(:user) { create(:user) }
    let(:preference) { false }
    let(:user_notification) do
      create(
        :user_notification,
        user: user,
        course_create: preference,
        course_update: preference,
      )
    end

    subject { described_class.new(user_id: user.id) }

    describe "enabled?" do
      context "when there are no user notifications" do
        it "returns false" do
          expect(subject.enabled?).to eq(false)
        end
      end

      context "when there are notifications" do
        before { user_notification }

        context "when the preferences are set to false" do
          let(:preference) { false }

          it "returns false" do
            expect(subject.enabled?).to eq(false)
          end
        end

        context "when the preferences are set to true" do
          let(:preference) { true }

          it "returns true" do
            expect(subject.enabled?).to eq(true)
          end
        end
      end
    end

    describe "updated_at" do
      context "when not previously set" do
        it "returns nil" do
          expect(subject.updated_at).to be_nil
        end
      end

      context "when previously set" do
        let(:user_notifications) do
          [
            user_notification,
            create(:user_notification, user: user),
          ]
        end

        it "returns the latest updated_at of the UserNotification records" do
          max_updated_at = user_notifications.map(&:updated_at).max

          expect(subject.updated_at).to eq(max_updated_at.iso8601)
        end
      end
    end
  end

  describe "#update" do
    let(:organisation) { create(:organisation) }
    let(:organisation2) { create(:organisation) }

    let(:accredited_body1) { create(:provider, :accredited_body) }
    let(:accredited_body2) { create(:provider, :accredited_body) }

    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    let(:user_notification1) do
      create(
        :user_notification,
        user: user,
        course_create: false,
        course_update: false,
        provider_code: accredited_body1.provider_code,
      )
    end

    let(:user_notification2) do
      create(
        :user_notification,
        user: user,
        course_create: false,
        course_update: false,
        provider_code: accredited_body2.provider_code,
      )
    end

    let(:other_users_notification) do
      create(
        :user_notification,
        user: other_user,
        course_create: false,
        course_update: false,
        provider_code: accredited_body1.provider_code,
      )
    end

    context "user has no notifications" do
      before do
        user
        organisation.users << user
        organisation.providers = [accredited_body1, accredited_body2]
      end

      it "creates user notification preference for each accredited body" do
        user_notification_preferences = described_class.new(user_id: user.id).update(enable_notifications: true)

        expect(user_notification_preferences.enabled?).to eq(true)
        user_notifications = UserNotification.where(user_id: user.id)
        expect(user_notifications.count).to eq(2)
        expect(user_notifications.map(&:course_create)).to eq([true, true])
        expect(user_notifications.map(&:course_update)).to eq([true, true])
        expect(user_notifications.map(&:provider_code)).to contain_exactly(accredited_body1.provider_code, accredited_body2.provider_code)
      end

      context "when the user has duplicate provider associations" do
        before do
          user
          organisation2.users << user
          organisation2.providers = [accredited_body1, accredited_body2]
        end

        it "doesn't create duplicate user notification preferences" do
          described_class.new(user_id: user.id).update(enable_notifications: true)

          user_notifications = UserNotification.where(user_id: user.id)
          expect(user_notifications.count).to eq(2)
        end
      end
    end

    context "user has existing notifications" do
      before do
        user
        other_user
        organisation.users << user
        organisation.providers = [accredited_body1, accredited_body2]
        user_notification1
        user_notification2
        other_users_notification
      end

      it "updates their notifications" do
        user_notification_preferences = described_class.new(user_id: user.id).update(enable_notifications: true)

        expect(user_notification_preferences.enabled?).to eq(true)
        user_notifications = UserNotification.where(user_id: user.id)
        expect(user_notifications.count).to eq(2)
        expect(user_notifications.map(&:course_create)).to eq([true, true])
        expect(user_notifications.map(&:course_update)).to eq([true, true])
        expect(user_notifications.map(&:provider_code))
          .to contain_exactly(accredited_body1.provider_code, accredited_body2.provider_code)
      end

      it "resets enabled after update" do
        user_notification_preferences = described_class.new(user_id: user.id)
        pre_enabled = user_notification_preferences.enabled?
        expect(pre_enabled).to eq(false)

        user_notification_preferences.update(enable_notifications: true)
        expect(user_notification_preferences.enabled?).to eq(true)
      end

      it "doesn't update other users notifications" do
        described_class.new(user_id: user.id).update(enable_notifications: true)

        other_users_notification_preferences = UserNotification.where(user_id: other_user.id)
        expect(other_users_notification_preferences.map(&:course_create)).to eq([false])
      end

      describe "if an error is raised" do
        before do
          allow(UserNotification).to receive(:create).and_raise(StandardError)
        end

        it "does not commit the changes to the DB" do
          described_class.new(user_id: user.id).update(enable_notifications: true)

          user_notifications = UserNotification.where(user_id: user.id)
          expect(user_notifications.count).to eq(2)
          expect(user_notifications.map(&:course_create)).to eq([false, false])
          expect(user_notifications.map(&:course_update)).to eq([false, false])
        end

        it "reports the error" do
          expect(Raven).to receive(:capture).with(instance_of(StandardError))
          described_class.new(user_id: user.id).update(enable_notifications: true)
        end
      end
    end

    context "user has changed accredited body associations" do
      context "accredited body removed" do
        before do
          user
          other_user
          organisation.users << user
          organisation.providers = [accredited_body1]
          user_notification1
          user_notification2
        end

        it "removes the unassociated accredited body UserNotification" do
          described_class.new(user_id: user.id).update(enable_notifications: true)
          user_notifications = UserNotification.where(user_id: user.id)

          expect(user_notifications.count).to eq(1)
          expect(user_notifications.map(&:provider_code))
            .to contain_exactly(accredited_body1.provider_code)
        end
      end

      context "accredited body added" do
        let(:accredited_body3) { create(:provider, :accredited_body) }

        before do
          user
          other_user
          organisation.users << user
          organisation.providers = [accredited_body1, accredited_body2, accredited_body3]
          user_notification1
          user_notification2
        end

        it "creates a UserNotification for the new accredited body notification" do
          described_class.new(user_id: user.id).update(enable_notifications: true)
          user_notifications = UserNotification.where(user_id: user.id)

          expect(user_notifications.count).to eq(3)
          expect(user_notifications.map(&:provider_code))
            .to contain_exactly(
              accredited_body1.provider_code,
              accredited_body2.provider_code,
              accredited_body3.provider_code,
            )
        end
      end
    end
  end
end
