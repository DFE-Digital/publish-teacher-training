require "rails_helper"

shared_examples "Unauthenticated, unauthorised, or not accepted T&Cs" do
  context "when unauthenticated" do
    let(:payload) { { email: "foo@bar" } }

    it { is_expected.to have_http_status(:unauthorized) }
  end

  context "when user has not accepted terms" do
    let(:user) { create(:user, :inactive) }
    let(:provider) { create(:provider, users: [user]) }

    it { is_expected.to have_http_status(:forbidden) }

    it "Returns the correct error type" do
      body = JSON.parse(subject.body)
      expect(body["meta"]).to eq("error_type" => "user_not_accepted_terms_and_conditions")
    end
  end

  context "when user has been discarded" do
    let(:user) { create(:user) }
    let(:provider) { create(:provider, users: [user]) }

    before do
      user.discard
    end

    it { is_expected.to have_http_status(:forbidden) }

    it "Returns the correct error type" do
      body = JSON.parse(subject.body)
      expect(body["meta"]).to eq("error_type" => "user_has_been_removed")
    end
  end

  context "when unauthorised" do
    let(:unauthorised_user) { create(:user) }
    let(:payload)           { { email: unauthorised_user.email } }

    it "raises an error" do
      expect { subject }.to raise_error Pundit::NotAuthorizedError
    end
  end
end
