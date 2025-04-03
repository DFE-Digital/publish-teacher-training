# frozen_string_literal: true

require "rails_helper"

describe UserPolicy do
  let(:user) { create(:user) }
  let(:unauthorised_user) { create(:user) }
  let(:admin) { create(:user, :admin) }

  describe "show?" do
    it "allows seeing your own info only" do
      expect(described_class.new(user, user)).to be_show
    end

    it "doesn't allows seeing another user's info info only" do
      expect(described_class.new(unauthorised_user, user)).not_to be_show
    end
  end

  describe "remove_access_to" do
    it "allows the user to remove themselves from an organisation" do
      expect(described_class.new(user, user)).to be_remove_access_to
    end

    it "allows the admin to remove a user from an organisation" do
      expect(described_class.new(admin, user)).to be_remove_access_to
    end

    it "prevents a user from removing another user from an organisation" do
      expect(described_class.new(unauthorised_user, user)).not_to be_remove_access_to
    end
  end
end
