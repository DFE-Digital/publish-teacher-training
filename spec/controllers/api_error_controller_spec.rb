require "rails_helper"

RSpec.describe APIErrorController do
  describe "GET error500" do
    it "throws an error" do
      expect do
        get :error500
      end.to raise_exception RuntimeError
    end
  end
end
