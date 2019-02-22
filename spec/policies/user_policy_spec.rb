require "rails_helper"

describe UserPolicy do
  describe 'show?' do
    let(:user) { create(:user) }

    it 'allows seeing your own info only' do
      expect(UserPolicy.new(user, user).show?).to be_truthy
    end

    it "doesn't allows seeing another user's info info only" do
      another_user = create(:user)

      expect(UserPolicy.new(user, another_user).show?).to be_falsey
    end
  end
end
