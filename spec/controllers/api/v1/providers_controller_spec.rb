require 'rails_helper'

describe API::V1::ProvidersController, type: :controller do
  describe "index" do
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
      before do
        allow(controller).to receive(:authenticate)
      end

      subject { Rack::Utils.parse_query(URI(response.headers['Link']).query) }

      context 'with two providers changed at different times' do
        let!(:old_provider)  { create(:provider, changed_at: 5.minute.ago.utc) }
        let!(:last_provider) { create(:provider, changed_at: 1.minute.ago.utc) }

        before do
          get :index, params: { changed_since: changed_since.iso8601 }
        end

        context 'using a changed_since before any providers have changed' do
          let(:changed_since) { 10.minutes.ago.utc }

          its(%w[per_page]) { should eq '100' }
          its(%w[changed_since]) do
            should eq last_provider.changed_at.strftime('%FT%T.%6NZ')
          end
        end

        context 'using a changed_since after any providers have changed' do
          let(:changed_since) { Time.now.utc }

          its(%w[per_page]) { should eq '100' }
          its(%w[changed_since]) { should eq changed_since.iso8601 }
        end
      end

      context 'with no providers at all' do
        let(:changed_since) { DateTime.now.utc }

        before do
          get :index, params: { changed_since: changed_since.iso8601 }
        end

        its(%w[per_page]) { should eq '100' }
        its(%w[changed_since]) { should eq changed_since.iso8601 }
      end
    end
  end
end
