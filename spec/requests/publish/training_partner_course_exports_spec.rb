# frozen_string_literal: true

require "rails_helper"

describe "Publish::ProvidersController" do
  include DfESignInUserHelper

  describe "/publish/providers/suggest" do
    context "when the user is authenticated" do
      it "is successful" do
        provider = create(:provider)
        user = create(:user, providers: [provider])

        login_user(user)
        get "/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle.year}/training-providers-courses.csv"
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
