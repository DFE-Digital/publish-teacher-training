require 'rails_helper'

RSpec.describe Api::V1::ProvidersController, type: :controller do
  describe "index" do
    it "render service unavailable" do
      allow(controller).to receive(:index).and_raise(PG::ConnectionBad)
      allow(controller).to receive(:authenticate)

      get :index
      expect(response).to have_http_status(:service_unavailable)
      json = JSON.parse(response.body)
      expect(json). to eq(
        'code' => 503, 'status' => 'Service Unavailable'
      )
    end

    it "calls limit on the model with default value of 100" do
      allow(controller).to receive(:authenticate)
      expect(Provider).to receive_message_chain(:changed_since, :limit).with(100).and_return([])

      get :index
    end

    it 'renders a 400 when the changed_since param is not valid' do
      allow(controller).to receive(:authenticate)

      get :index, params: { changed_since: '2019' }
      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json). to include(
        'status' => 400
      )
    end

    describe 'generated next link' do
      let!(:oldy_provider) { create(:provider, last_published_at: 5.minute.ago.utc) }
      let!(:last_provider) { create(:provider, last_published_at: 1.minute.ago.utc) }
      let(:last_provider_id) { last_provider.id }

      before do
        allow(controller).to receive(:authenticate)

        get :index, params: { changed_since: 10.minutes.ago.utc }
      end

      subject { response.headers['Link'] }

      it { is_expected.to match %r{changed_since=#{(last_provider.last_published_at + 1.second).iso8601}} }
      it { is_expected.to match %r{from_provider_id=#{last_provider_id}} }
    end
  end
end
