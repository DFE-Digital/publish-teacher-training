# frozen_string_literal: true

require "rails_helper"

describe UserNotification do
  describe "validations" do
    it { is_expected.to validate_presence_of(:course_publish).with_message("is not included in the list") }
    it { is_expected.to validate_presence_of(:course_update).with_message("is not included in the list") }
  end

  describe "associations" do
    subject { described_class.new(user_id: user.id, provider_code: provider.provider_code) }

    let(:organisation) { create(:organisation, providers: [provider]) }
    let(:user) { create(:user, organisations: [organisation]) }
    let(:provider) { create(:provider) }

    it { is_expected.to belong_to(:provider) }
    it { is_expected.to belong_to(:user) }
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
      subject { described_class.course_publish_notification_requests(provider.provider_code) }

      before do
        user_notification_create
        user_notification_update
      end

      it { is_expected.to contain_exactly(user_notification_create) }
    end

    describe ".course_update_notification_requests" do
      subject { described_class.course_update_notification_requests(provider.provider_code) }

      before do
        user_notification_create
        user_notification_update
      end

      it { is_expected.to contain_exactly(user_notification_update) }
    end
  end
end
