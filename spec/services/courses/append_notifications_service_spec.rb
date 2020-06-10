require "rails_helper"

RSpec.describe Courses::AppendNotificationsService do
  let!(:course) { create(:course, :with_accrediting_provider) }
  let(:provider) { course.provider }
  let(:accredited_body) { course.accrediting_provider }
  let(:user) { accredited_body.users.first }

  subject do
    described_class.new(course: new_course)
  end

  describe "#call" do
    context "when new provider" do
      context "when user has another notifications" do
        let(:new_course) do
          create(:course, accrediting_provider: accredited_body)
        end

        before do
          create(:user_notification, user: user, provider: provider)
        end

        it "appends missing notification" do
          expect {
            subject.call
          }.to change(UserNotification, :count).by(1)
        end
      end

      context "when user has does not have any notifications" do
        let(:new_course) do
          create(:course, accrediting_provider: accredited_body)
        end

        it "does not append any further notifications" do
          expect {
            subject.call
          }.to_not change(UserNotification, :count)
        end
      end
    end

    context "when existing provider" do
      context "when notification pair already exists" do
        let(:new_course) do
          create(:course, accrediting_provider: accredited_body, provider: provider)
        end

        before do
          create(:user_notification, user: user, provider: provider)
        end

        it "appends missing notification" do
          expect {
            subject.call
          }.to_not change(UserNotification, :count)
        end
      end
    end

    context "when new accredited_body" do
      it
    end
  end
end
