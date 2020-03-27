# == Schema Information
#
# Table name: user_notification
#
#  course_create :boolean          default(FALSE)
#  course_update :boolean          default(FALSE)
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

  describe "scopes" do
    let(:organisation) { create(:organisation, providers: [provider]) }
    let(:user) { create(:user, organisations: [organisation]) }
    let(:provider) { create(:provider) }
    let(:user_notification_create) do
      create(
        :user_notification,
        provider_code: provider.provider_code,
        user_id: user.id,
        course_create: true,
      )
    end

    let(:user_notification_update) do
      create(
        :user_notification,
        provider_code: provider.provider_code,
        user_id: user.id,
        course_update: true,
      )
    end

    describe ".course_create_notification_requests" do
      subject { described_class.course_create_notification_requests(provider.provider_code) }
      it { should contain_exactly(user_notification_create) }
    end

    describe ".course_update_notification_requests" do
      subject { described_class.course_update_notification_requests(provider.provider_code) }
      it { should contain_exactly(user_notification_update) }
    end
  end
end
