require "rails_helper"

describe UserNotification, type: :model do
  describe "validations" do
    before do
      subject.valid?
    end

    it "requires course_publish" do
      subject.course_publish = nil
      subject.save
      expect(subject.errors["course_publish"]).to include("is not included in the list")
    end

    it "requires course_update" do
      subject.course_update = nil
      subject.save
      expect(subject.errors["course_update"]).to include("is not included in the list")
    end
  end

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
        course_publish: true,
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

    describe ".course_publish_notification_requests" do
      before do
        user_notification_create
        user_notification_update
      end

      subject { described_class.course_publish_notification_requests(provider.provider_code) }

      it { should contain_exactly(user_notification_create) }
    end

    describe ".course_update_notification_requests" do
      before do
        user_notification_create
        user_notification_update
      end

      subject { described_class.course_update_notification_requests(provider.provider_code) }

      it { should contain_exactly(user_notification_update) }
    end
  end
end
