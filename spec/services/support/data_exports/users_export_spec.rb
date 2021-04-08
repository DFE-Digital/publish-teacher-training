require "rails_helper"

RSpec.describe Support::DataExports::UsersExport do
  context "columns" do
    it "returns expected values" do
      expect(subject.id).to eql("users")
      expect(subject.name).to eql("All users")
      expect(subject.description).to eql("The list of all users with columns: provider_code, provider_name, provider_type, first_name, last_name, email_address")
      expect(subject.id).to eql("users")
    end
  end

  context ".user_data" do
    let(:user) { build(:user) }
    let(:provider) { build(:provider) }

    it "returns hash of user data" do
      res = subject.user_data(user, provider)
      expect(res).to eql(
        {
          provider_code: provider.provider_code,
          provider_name: provider.provider_name,
          provider_type: provider.provider_type,
          first_name: user.first_name,
          last_name: user.last_name,
          email_address: user.email,
        }
      )
    end

    it "returns hash of user data with empty provider" do
      res = subject.user_data(user, nil)
      expect(res).to eql(
        {
          provider_code: nil,
          provider_name: nil,
          provider_type: nil,
          first_name: user.first_name,
          last_name: user.last_name,
          email_address: user.email,
        }
      )
    end
  end

  context ".data" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    before do
      user1
      user2
    end

    it "returns array of user_data" do
      res = subject.data
      expect(res).to eql([
        {
          provider_code: nil,
          provider_name: nil,
          provider_type: nil,
          first_name: user1.first_name,
          last_name: user1.last_name,
          email_address: user1.email,
        },
        {
          provider_code: nil,
          provider_name: nil,
          provider_type: nil,
          first_name: user2.first_name,
          last_name: user2.last_name,
          email_address: user2.email,
        },
      ])
    end
  end
end
