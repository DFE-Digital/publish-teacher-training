require "rails_helper"

describe SignInController, type: :controller do
  describe "#index" do
    it "renders the index page" do
      get :index
      expect(response).to render_template("sign_in/index")
    end
  end
end
