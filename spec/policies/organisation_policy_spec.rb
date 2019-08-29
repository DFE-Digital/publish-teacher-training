require "rails_helper"

describe OrganisationPolicy do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:organisation) { create(:organisation) }

  describe 'add_user?' do
    it 'allows a user to be added by an admin' do
      expect(described_class.new(admin, organisation).add_user?).to be_truthy
    end

    it "doesn't allow a non-admin to add a user" do
      expect(described_class.new(user, organisation).add_user?).to be_falsey
    end
  end
end
