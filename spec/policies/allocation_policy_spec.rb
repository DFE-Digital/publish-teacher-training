require "rails_helper"

describe AllocationPolicy do
  subject { described_class }

  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:organisation) { create(:organisation, users: [user]) }
  let(:accredited_body) { create(:provider, :accredited_body) }
  let(:training_provider) { create(:provider) }
  let(:allocation) { build(:allocation, accredited_body: accredited_body, provider: training_provider) }

  permissions :create? do
    context "a user that belongs to the allocation accredited body" do
      before do
        organisation.providers << accredited_body
      end

      it { is_expected.to permit(user, allocation) }
    end

    context "a user that belongs to the provider" do
      before do
        organisation.providers << training_provider
      end

      it { is_expected.not_to permit(user, allocation) }
    end

    context "a user doesn't belong to the accredited body or the provider" do
      it { is_expected.not_to permit(user, allocation) }
    end

    context "a user that is an admin" do
      it { is_expected.to permit(admin, allocation) }
    end
  end
end
