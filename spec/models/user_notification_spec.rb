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

    describe ".find_or_initialize" do
      context "Initialization" do
        unknown_provider_code = "ABC"
        subject { described_class.find_or_initialize(unknown_provider_code) }

        it { is_expected.to_not eq(user_notification_create) }
        it { is_expected.to be_an_instance_of(UserNotification) }
      end

      context "Finding" do
        before do
          user_notification_create
        end

        subject { described_class.find_or_initialize(provider.provider_code) }

        it { is_expected.to eq(user_notification_create) }
      end
    end
  end
end
