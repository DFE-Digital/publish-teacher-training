# frozen_string_literal: true

require "rails_helper"

module UserSessions
  describe Update do
    describe ".call" do
      let(:service) { described_class.call(user: user, user_session: user_session) }

      context "when user are valid" do
        let(:user) { create(:user) }

        let(:user_session) do
          template = build(:user)
          UserSession.new(email: template.email,
                          sign_in_user_id: template.sign_in_user_id,
                          first_name: template.first_name,
                          last_name: template.last_name)
        end

        before do
          service.call
          user.reload
        end

        it "updates the user's details" do
          expect(user.email).to eq(user_session.email)
          expect(user.sign_in_user_id).to eq(user_session.sign_in_user_id)
          expect(user.first_name).to eq(user_session.first_name)
          expect(user.last_name).to eq(user_session.last_name)
        end

        it "is successful" do
          expect(service).to be_successful
        end
      end

      context "when the user's details are invalid" do
        let(:user) { create(:user) }

        let(:user_session) do
          UserSession.new(email: nil,
                          sign_in_user_id: nil,
                          first_name: nil,
                          last_name: nil)
        end

        before do
          service.call
          user.reload
        end

        it "does not update the user's details" do
          expect(user.email).not_to eq(user_session.email)
          expect(user.sign_in_user_id).not_to eq(user_session.sign_in_user_id)
          expect(user.first_name).not_to eq(user_session.first_name)
          expect(user.last_name).not_to eq(user_session.last_name)
        end

        it "is unsuccessful" do
          expect(service).not_to be_successful
        end
      end
    end
  end
end
