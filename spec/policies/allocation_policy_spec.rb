require "rails_helper"

describe AllocationPolicy do
  subject { described_class }

  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:organisation) { create(:organisation, users: [user]) }
  let(:accredited_body) { create(:provider, :accredited_body) }
  let(:training_provider) { create(:provider) }
  let(:allocation) do
    build(:allocation,
          accredited_body: accredited_body,
          provider: training_provider,
          number_of_places: 1)
  end

  permissions :index? do
    context "user is present" do
      it { is_expected.to permit(user, Allocation) }
    end

    context "user is not present" do
      let(:user) { nil }
      it { is_expected.not_to permit(user, Allocation) }
    end
  end

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
      let(:user) { create(:user, :admin) }

      it { is_expected.to permit(user, allocation) }
    end
  end

  describe AllocationPolicy::Scope do
    let(:allocation) do
      create(:allocation,
             accredited_body: accredited_body,
             provider: training_provider,
             number_of_places: 1)
    end

    subject { described_class.new(user, Allocation).resolve }

    context "a user that belongs to the allocation accredited body" do
      before { organisation.providers << accredited_body }

      it { is_expected.to contain_exactly(allocation) }
    end

    context "a user that doesn't belong to the allocation accredited body" do
      it { is_expected.not_to contain_exactly(allocation) }
    end

    context "an admin" do
      let(:user) { create(:user, :admin) }

      it { is_expected.to contain_exactly(allocation) }
    end
  end
end
