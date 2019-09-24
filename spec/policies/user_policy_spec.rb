require "rails_helper"

describe UserPolicy do
  let(:user) { create(:user) }
  let(:unauthorised_user) { create(:user) }
  let(:admin) { create(:user, :admin) }

  describe "show?" do
    it "allows seeing your own info only" do
      expect(described_class.new(user, user).show?).to be_truthy
    end

    it "doesn't allows seeing another user's info info only" do
      expect(described_class.new(unauthorised_user, user).show?).to be_falsey
    end
  end

  describe "remove_access_to" do
    it "allows the user to remove themselves from an organisation" do
      expect(described_class.new(user, user).remove_access_to?).to be_truthy
    end

    it "allows the admin to remove a user from an organisation" do
      expect(described_class.new(admin, user).remove_access_to?).to be_truthy
    end

    it "prevents a user from removing another user from an organisation" do
      expect(described_class.new(unauthorised_user, user).remove_access_to?).to be_falsey
    end
  end
end
