require "rails_helper"

RSpec.describe API::V2::UsersController do
  let(:user) { create(:user, :inactive) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:authenticate)
  end

  describe "#accept_terms" do
    it "updates accept_terms_date_utc" do
      put :accept_terms, params: { id: user.id }
      expect(user.reload.accept_terms_date_utc).to be_present
    end

    it "returns updated user json" do
      put :accept_terms, params: { id: user.id }
      expect(JSON.parse(response.body)["data"]["attributes"]["accept_terms_date_utc"]).to be_present
    end

    it "raises an error when the user is not saved" do
      allow(User).to receive(:find).and_return(user)
      allow(user).to receive(:save).and_return(false)
      user.errors.add(:email, "bar")
      put :accept_terms, params: { id: user.id }
      expect(JSON.parse(response.body)["errors"]).to eq([{ "title" => "Invalid email", "detail" => "Email bar", "source" => {} }])
      expect(response.status.to_i).to be(422)
    end
  end
end
