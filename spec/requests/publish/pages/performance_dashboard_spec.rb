# frozen_string_literal: true

require "rails_helper"

describe "Provider authorization spec" do
  # include DfESignInUserHelper

  describe "GET /performance-dashboard" do
    it "redirects twice to the first valid providers courses" do
      get "/performance-dashboard"
      expect(response).to be_successful
    end
  end
end
