# frozen_string_literal: true

require "rails_helper"

describe "Publish::ProvidersController" do
  include DfESignInUserHelper

  let(:user) { create(:user, :with_provider) }

  describe "/publish/providers/suggest" do
    context "when the user is authenticated" do
      it "is successful" do
        login_user(user)
        get "/publish/providers/suggest"
        expect(response).to have_http_status(:ok)
      end
    end

    context "when the user is not authenticated" do
      it "is successful" do
        get "/publish/providers/suggest"
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "/publish/providers/{authorized_provider_code}", travel: mid_cycle do
    let(:provider) { user.providers.first }

    context "when the user is authenticated" do
      it "is redirect to courses page of the users first provider" do
        login_user(user)
        get "/publish/organisations/#{provider.provider_code}"
        expect(response).to redirect_to("/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/courses")
      end
    end

    context "when the user is authenticated during rollover period", travel: find_closes do
      it "renders the cycle selector" do
        find_or_create(:recruitment_cycle, :next)
        login_user(user)
        get "/publish/organisations/#{provider.provider_code}"
        expect(response.parsed_body.text).to match("Recruitment cycles")
      end
    end

    context "when the user is not authenticated" do
      it "is redirect to sign-in path" do
        get "/publish/organisations/#{provider.provider_code}"
        expect(response).to redirect_to("/sign-in")
      end
    end
  end

  describe "/publish/providers/{unauthorized_provider_code}" do
    let(:other_provider) { create(:provider) }

    context "when the user is authenticated" do
      it "is forbidden" do
        login_user(user)
        get "/publish/organisations/#{other_provider.provider_code}"
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when the user is not authenticated" do
      it "is redirect to sign-in path" do
        get "/publish/organisations/#{other_provider.provider_code}"
        expect(response).to redirect_to("/sign-in")
      end
    end
  end

  describe "/publish/providers/{invalid_provider_code}" do
    context "when the user is authenticated" do
      it "is not found" do
        login_user(user)
        get "/publish/organisations/ZZZ"
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the user is not authenticated" do
      it "is redirect to sign-in path" do
        get "/publish/organisations/ZZZ"
        expect(response).to redirect_to("/sign-in")
      end
    end
  end
end
