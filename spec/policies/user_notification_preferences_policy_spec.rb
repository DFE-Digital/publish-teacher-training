require "rails_helper"

describe UserNotificationPreferencesPolicy do
  subject { described_class }

  let(:user) { create(:user) }

  permissions :show? do
    context "when the user matches" do
      it { is_expected.to permit(user, double(id: user.id)) }
    end

    context "when the user doesn't match" do
      it { is_expected.not_to permit(user, double(id: user.id + 1)) }
    end
  end

  permissions :update? do
    context "when the user matches" do
      it { is_expected.to permit(user, double(id: user.id)) }
    end

    context "when user doesn't match" do
      it { is_expected.not_to permit(user, double(id: user.id + 1)) }
    end
  end
end
