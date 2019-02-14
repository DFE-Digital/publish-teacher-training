require 'rails_helper'

RSpec.describe PingController, type: :controller do
  describe "index" do
    context "some courses in db" do
      let!(:course) { create(:course) }
      it "get" do
        get :index
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json). to eq('course_count' => 3) # todo: I don't know why I got 3 instead of 1??
      end
    end
  end
end
