require "rails_helper"

describe "heartbeat requests" do
  describe "GET /ping" do
    it "returns PONG" do
      get "/ping"

      expect(response.body).to eq "PONG"
    end
  end

  describe "GET /healthcheck" do
    before do
      retry_set = instance_double(Sidekiq::RetrySet, size: 0)
      allow(Sidekiq::RetrySet).to receive(:new).and_return(retry_set)
    end

    context "when a problem exists" do
      before do
        allow(ActiveRecord::Base.connection)
          .to receive(:active?).and_return(false)
        allow(Sidekiq).to receive(:redis_info).and_raise(Errno::ECONNREFUSED)
        process_set = instance_double(Sidekiq::ProcessSet, size: 0)
        allow(Sidekiq::ProcessSet).to receive(:new).and_return(process_set)
        dead_set = instance_double(Sidekiq::DeadSet, size: 1)
        allow(Sidekiq::DeadSet).to receive(:new).and_return(dead_set)
      end

      it "returns status service unavailable" do
        get "/healthcheck"
        expect(response.status).to eq(503)
      end

      it "returns the expected response report" do
        get "/healthcheck"
        expect(response.body).to eq({ checks: {
          database: false,
          redis: false,
          sidekiq: false,
          sidekiq_queue: false,
        } }.to_json)
      end
    end

    context "when everything is ok" do
      before do
        allow(ActiveRecord::Base.connection)
          .to receive(:active?).and_return(true)
        allow(Sidekiq).to receive(:redis_info).and_return({})
        process_set = instance_double(Sidekiq::ProcessSet, size: 1)
        allow(Sidekiq::ProcessSet).to receive(:new).and_return(process_set)
        dead_set = instance_double(Sidekiq::DeadSet, size: 0)
        allow(Sidekiq::DeadSet).to receive(:new).and_return(dead_set)
      end

      it "returns HTTP success" do
        get "/healthcheck"
        expect(response.status).to eq(200)
      end

      it "returns JSON" do
        get "/healthcheck"
        expect(response.content_type).to eq("application/json; charset=utf-8")
      end

      it "returns the expected response report" do
        get "/healthcheck"
        expect(response.body).to eq({ checks: {
          database: true,
          redis: true,
          sidekiq: true,
          sidekiq_queue: true,
        } }.to_json)
      end
    end
  end
end
