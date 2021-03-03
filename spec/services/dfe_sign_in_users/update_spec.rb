# frozen_string_literal: true

require "rails_helper"

module DfESignInUsers
  describe Update do
    describe ".call" do
      let(:service) { described_class.call(user: user, dfe_sign_in_user: dfe_sign_in_user) }

      context "when user are valid" do
        let(:user) { create(:user) }

        let(:dfe_sign_in_user) do
          template = build(:user)
          DfESignInSession.new(email: template.email,
                               sign_in_user_id: template.sign_in_user_id,
                               first_name: template.first_name,
                               last_name: template.last_name)
        end

        before do
          service.call
          user.reload
        end

        it "updates the user's details" do
          expect(user.email).to eq(dfe_sign_in_user.email)
          expect(user.sign_in_user_id).to eq(dfe_sign_in_user.sign_in_user_id)
          expect(user.first_name).to eq(dfe_sign_in_user.first_name)
          expect(user.last_name).to eq(dfe_sign_in_user.last_name)
        end

        it "is successful" do
          expect(service).to be_successful
        end
      end

      context "when the user's details are invalid" do
        let(:user) { create(:user) }

        let(:dfe_sign_in_user) do
          DfESignInSession.new(email: nil,
                               sign_in_user_id: nil,
                               first_name: nil,
                               last_name: nil)
        end

        before do
          service.call
          user.reload
        end

        it "does not update the user's details" do
          expect(user.email).to_not eq(dfe_sign_in_user.email)
          expect(user.sign_in_user_id).to_not eq(dfe_sign_in_user.sign_in_user_id)
          expect(user.first_name).to_not eq(dfe_sign_in_user.first_name)
          expect(user.last_name).to_not eq(dfe_sign_in_user.last_name)
        end

        it "is unsuccessful" do
          expect(service).to_not be_successful
        end
      end
    end
  end
end
