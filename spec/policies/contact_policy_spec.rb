require "rails_helper"

describe ContactPolicy do
  let(:user) { create(:user) }
  let(:provider) { create(:provider) }
  let(:contact) { create(:contact, provider:) }

  subject { described_class }

  permissions :show?, :update? do
    context "a user that belongs to the provider" do
      before do
        provider.users << user
      end

      it { is_expected.to permit(user, contact) }
    end

    context "a user doesn't belong to the provider" do
      it { is_expected.not_to permit(user, contact) }
    end

    context "a user that is an admin" do
      let(:user) { create(:user, :admin) }

      it { is_expected.to permit(user, contact) }
    end
  end
end
