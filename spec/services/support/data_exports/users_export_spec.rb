require "rails_helper"

RSpec.describe Support::DataExports::UsersExport do
  context "columns" do
    it "returns expected values" do
      expect(subject.type).to eql("users")
    end
  end

  describe ".user_data" do
    let(:user) { build(:user) }
    let(:provider) { build(:provider) }

    it "returns hash of user data" do
      res = subject.send(:user_data, user, provider)
      expect(res).to eql(
        {
          provider_code: provider.provider_code,
          provider_name: provider.provider_name,
          provider_type: provider.provider_type,
          first_name: user.first_name,
          last_name: user.last_name,
          email_address: user.email,
        },
      )
    end
  end

  describe ".data" do
    let(:provider) { create(:provider, organisations: []) }
    let(:organisation) { create(:organisation, users: [], providers: [provider]) }
    let(:user1) { create(:user, organisations: [organisation]) }
    let(:user2) { create(:user, organisations: [organisation]) }

    before do
      user1
      user2
    end

    it "returns array of user_data" do
      res = subject.data
      expect(res).to eql([
        {
          provider_code: user1.providers.first.provider_code,
          provider_name: user1.providers.first.provider_name,
          provider_type: user1.providers.first.provider_type,
          first_name: user1.first_name,
          last_name: user1.last_name,
          email_address: user1.email,
        },
        {
          provider_code: user2.providers.first.provider_code,
          provider_name: user2.providers.first.provider_name,
          provider_type: user2.providers.first.provider_type,
          first_name: user2.first_name,
          last_name: user2.last_name,
          email_address: user2.email,
        },
      ])
    end
  end
end
