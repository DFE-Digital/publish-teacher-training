require "rails_helper"

describe "GET /reporting" do
  it "returns status success" do
    get "/reporting"
    expect(response.status).to eq(200)
  end
end
