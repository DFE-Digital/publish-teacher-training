RSpec.describe Provider, type: :model do
  describe ".with_user" do
    context "30 days ago" do
      let(:over_30_user) { create(:user, last_login_date_utc: 30.days.ago) }
      let(:under_30_user) { create(:user, last_login_date_utc: 29.days.ago) }

      let(:now_user) { create(:user, last_login_date_utc: DateTime.now.utc) }

      let(:organisations) do
        [create(:organisation, users: [over_30_user, under_30_user, now_user])]
      end

      let!(:provider) do
        create(:provider, organisations: organisations)
      end

      it "includes provider with users logged in less than 30 days ago" do
        expect(described_class.with_users(User.last_login_since(30.days.ago))).to eq([provider, provider])
      end
    end
  end
end
