require "rails_helper"

describe AccessRequestPolicy do
  subject { described_class }

  permissions :approve? do
    let(:access_request) { build(:access_request) }

    context 'non-admin user' do
      let(:user) { build(:user) }

      it { should_not permit(user, access_request) }
    end

    context 'admin user' do
      let(:user) { build(:user, :admin) }

      it { should permit(user, access_request) }
    end
  end
end
