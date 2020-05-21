require "rails_helper"

describe API::V2::SerializableUserNotificationPreferences do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
  let(:updated_at) { Time.current }
  let(:user_notification_preferences) do
    instance_double(UserNotificationPreferences, id: 1, enabled: true, updated_at: updated_at)
  end

  subject { described_class.new(object: user_notification_preferences) }

  it "sets type to user_notification_preferences" do
    expect(subject.jsonapi_type).to eq :user_notification_preferences
  end

  it "has a enabled attribute" do
    expect(subject.as_jsonapi[:attributes][:enabled]).to eq(true)
  end

  it "has a updated_at attribute" do
    expect(subject.as_jsonapi[:attributes][:updated_at]).to eq(updated_at)
  end
end
