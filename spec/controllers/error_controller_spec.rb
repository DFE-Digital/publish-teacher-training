require 'rails_helper'

RSpec.describe ErrorController, type: :controller do
  describe "GET error_500" do
    it "throws an error" do
      expect {
        get :error_500
      }.to raise_exception RuntimeError
    end
  end
end
