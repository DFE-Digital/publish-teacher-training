# frozen_string_literal: true

require "rails_helper"

module Publish
  module Authentication
    module UserSessions
      describe Update do
        describe ".call" do
          let(:service) { described_class.call(user:, omniauth_payload:) }

          context "when user are valid" do
            let(:user) { create(:user) }

            let(:omniauth_payload) do
              template = build(:user)
              {
                "uid" => template.sign_in_user_id,
                "info" => {
                  "email" => template.email,
                  "first_name" => template.first_name,
                  "last_name" => template.last_name,
                },
              }
            end

            before do
              service.call
              user.reload
            end

            it "updates the user's details" do
              expect(user.email).to eq(omniauth_payload["info"]["email"].downcase)
              expect(user.sign_in_user_id).to eq(omniauth_payload["uid"])
              expect(user.first_name).to eq(omniauth_payload["info"]["first_name"])
              expect(user.last_name).to eq(omniauth_payload["info"]["last_name"])
            end

            it "is successful" do
              expect(service).to be_successful
            end
          end

          context "when the user's details are invalid" do
            let(:user) { create(:user) }

            let(:omniauth_payload) do
              {
                "uid" => nil,
                "info" => {
                  "email" => nil,
                  "first_name" => nil,
                  "last_name" => nil,
                },
              }
            end

            before do
              service.call
              user.reload
            end

            it "does not update the user's details" do
              expect(user.email).not_to eq(omniauth_payload["info"]["email"])
              expect(user.sign_in_user_id).not_to eq(omniauth_payload["uid"])
              expect(user.first_name).not_to eq(omniauth_payload["info"]["first_name"])
              expect(user.last_name).not_to eq(omniauth_payload["info"]["last_name"])
            end

            it "is unsuccessful" do
              expect(service).not_to be_successful
            end
          end
        end
      end
    end
  end
end
