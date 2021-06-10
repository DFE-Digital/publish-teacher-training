require "rails_helper"

describe "Interrupt page acknowledgements API v2", type: :request do
  let(:user)         { create(:user) }
  let(:cycle)        { find_or_create :recruitment_cycle }
  let(:payload)      { { email: user.email } }
  let(:credentials) { encode_to_credentials(payload) }

  describe "index" do
    before do
      create(:interrupt_page_acknowledgement, user: user, recruitment_cycle: cycle, page: :rollover)
      create(:interrupt_page_acknowledgement, user: user, recruitment_cycle: cycle, page: :rollover_recruitment)
    end

    let(:path) do
      "/api/v2/recruitment_cycles/#{cycle.year}/users/#{user.id}/interrupt_page_acknowledgements"
    end

    subject do
      get path,
          headers: { "HTTP_AUTHORIZATION" => credentials }
      response
    end

    it "lists all the acknowlegements for the user for that year" do
      json_response = JSON.parse subject.body
      pages = json_response["data"].map do |d|
        d["attributes"]["page"]
      end

      expect(pages).to contain_exactly("rollover", "rollover_recruitment")
    end

    context "trying to access another user's acknowledgements" do
      let(:other_user) { create(:user) }
      let(:path) do
        "/api/v2/recruitment_cycles/#{cycle.year}/users/#{other_user.id}/interrupt_page_acknowledgements"
      end

      it "gives an error" do
        expect { subject }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe "create" do
    let(:path) do
      "/api/v2/recruitment_cycles/#{cycle.year}/users/#{user.id}/interrupt_page_acknowledgements"
    end

    subject do
      post path,
           headers: { "HTTP_AUTHORIZATION" => credentials },
           params: {
             interrupt_page_acknowledgement: {
               page: "rollover",
             },
           }
      response
    end

    context "the acknowledgement doesn't exist" do
      it "creates an acknowlegement for that page/user/recruitment cycle" do
        expect { subject }.to change {
          user.interrupt_page_acknowledgements.count
        }.from(0).to(1)
        acknowledgement = user.interrupt_page_acknowledgements.take
        expect(acknowledgement.recruitment_cycle).to eq cycle
        expect(acknowledgement.page).to eq "rollover"
        expect(acknowledgement.user).to eq user
        expect(subject.status).to eq 200
      end
    end

    context "the acknowledgement does exist" do
      before do
        create(:interrupt_page_acknowledgement, user: user, recruitment_cycle: cycle, page: :rollover)
      end

      it "still returns success" do
        expect { subject }.to_not change {
          user.interrupt_page_acknowledgements.count
        }
        expect(subject.status).to eq 200
      end
    end

    context "trying to create an acknowledgement for a different user" do
      let(:other_user) { create(:user) }
      let(:path) do
        "/api/v2/recruitment_cycles/#{cycle.year}/users/#{other_user.id}/interrupt_page_acknowledgements"
      end

      it "gives an error" do
        expect { subject }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end
end
