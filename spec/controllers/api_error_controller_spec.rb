require "rails_helper"

RSpec.describe APIErrorController, type: :controller do
  describe "GET error500" do
    it "throws an error" do
      expect {
        get :error500
      }.to raise_exception RuntimeError
    end
  end
end
