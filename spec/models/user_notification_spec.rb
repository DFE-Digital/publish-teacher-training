# == Schema Information
#
# Table name: user_notification
#
#  course_create :boolean          default("false")
#  course_update :boolean          default("false")
#  created_at    :datetime         not null
#  id            :bigint           not null, primary key
#  provider_code :string           not null
#  updated_at    :datetime         not null
#  user_id       :integer          not null
#
# Indexes
#
#  index_user_notification_on_provider_code  (provider_code)
#
describe UserNotification, type: :model do
  describe "associations" do
    let(:organisation) { create(:organisation, providers: [provider]) }
    let(:user) { create(:user, organisations: [organisation]) }
    let(:provider) { create(:provider) }

    subject { described_class.new(user_id: user.id, provider_code: provider.provider_code) }

    it { should belong_to(:provider) }
    it { should belong_to(:user) }
  end
end
