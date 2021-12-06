require "rails_helper"

RSpec.describe Support::DataExports::UsersExport do
  context "columns" do
    it "returns expected values" do
      expect(subject.type).to eql("users")
    end
  end

  describe ".user_data" do
    let(:user) { build(:user, first_login_date_utc: 2.days.ago, last_login_date_utc: 1.day.ago) }
    let(:provider) { build(:provider) }

    it "returns hash of user data" do
      res = subject.send(:user_data, user, provider)
      expect(res).to eql(
        {
          user_id: user.id,
          provider_code: provider.provider_code,
          provider_name: provider.provider_name,
          provider_type: provider.provider_type,
          first_name: user.first_name,
          last_name: user.last_name,
          email_address: user.email,
          first_login_at: user.first_login_date_utc,
          last_login_at: user.last_login_date_utc,
          sign_in_user_id: user.sign_in_user_id,
        },
      )
    end
  end

  describe ".data" do
    let(:provider) { create(:provider, users: []) }
    let!(:user1) { create(:user, providers: [provider]) }
    let!(:user2) { create(:user, providers: [provider]) }

    it "returns array of user_data" do
      res = subject.data
      expect(res).to eql([
        {
          user_id: user1.id,
          provider_code: user1.providers.first.provider_code,
          provider_name: user1.providers.first.provider_name,
          provider_type: user1.providers.first.provider_type,
          first_name: user1.first_name,
          last_name: user1.last_name,
          email_address: user1.email,
          first_login_at: user1.first_login_date_utc,
          last_login_at: user1.last_login_date_utc,
          sign_in_user_id: user1.sign_in_user_id,
        },
        {
          user_id: user2.id,
          provider_code: user2.providers.first.provider_code,
          provider_name: user2.providers.first.provider_name,
          provider_type: user2.providers.first.provider_type,
          first_name: user2.first_name,
          last_name: user2.last_name,
          email_address: user2.email,
          first_login_at: user2.first_login_date_utc,
          last_login_at: user2.last_login_date_utc,
          sign_in_user_id: user2.sign_in_user_id,
        },
      ])
    end
  end
end
