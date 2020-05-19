require "rails_helper"

describe UserNotificationPreferencesPolicy do
  subject { described_class }

  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:organisation) { create(:organisation, users: [user]) }
  let(:accredited_body) { create(:provider, :accredited_body) }
  let(:notification) { build(:user_notification, user: user, provider: accredited_body) }

  permissions :index? do
    context "user is present" do
      it { is_expected.to permit(user, UserNotificationPreferences) }
    end

    context "user is not present" do
      let(:user) { nil }
      it { is_expected.not_to permit(user, UserNotificationPreferences) }
    end
  end

  permissions :update? do
    xcontext "a user that belongs to the notification accredited body" do
      before do
        organisation.providers << accredited_body
      end

      it { is_expected.to permit(user, notification) }
    end

    xcontext "a user doesn't belong to the accredited body" do
      it { is_expected.not_to permit(user, notification) }
    end

    xcontext "a user that is an admin" do
      let(:user) { create(:user, :admin) }

      it { is_expected.to permit(user, notification) }
    end
  end
end
