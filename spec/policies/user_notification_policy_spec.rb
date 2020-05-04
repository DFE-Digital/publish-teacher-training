require "rails_helper"

describe UserNotificationPolicy do
  subject { described_class }

  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:organisation) { create(:organisation, users: [user]) }
  let(:accredited_body) { create(:provider, :accredited_body) }
  let(:notification) { build(:user_notification, user: user, provider: accredited_body) }

  permissions :create? do
    context "a user that belongs to the notification accredited body" do
      before do
        organisation.providers << accredited_body
      end

      it { is_expected.to permit(user, notification) }
    end

    context "a user doesn't belong to the accredited body" do
      it { is_expected.not_to permit(user, notification) }
    end

    context "a user that is an admin" do
      let(:user) { create(:user, :admin) }

      it { is_expected.to permit(user, notification) }
    end
  end

  describe UserNotificationPolicy::Scope do
    let!(:notification) { create(:user_notification, user: user, provider: accredited_body) }

    subject { described_class.new(user, UserNotification).resolve }

    context "a user that belongs to the notification accredited body" do
      before { organisation.providers << accredited_body }

      it { is_expected.to contain_exactly(notification) }
    end

    context "a user that doesn't belong to the notification accredited body" do
      it { is_expected.not_to contain_exactly(notification) }
    end

    context "an admin" do
      let(:user) { create(:user, :admin) }

      it { is_expected.to contain_exactly(notification) }
    end
  end
end
