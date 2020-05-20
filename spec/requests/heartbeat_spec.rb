require "rails_helper"

describe "heartbeat requests" do
  describe "GET /ping" do
    it "returns PONG" do
      get "/ping"

      expect(response.body).to eq "PONG"
    end
  end

  describe "GET /healthcheck" do
    let(:stats)      { instance_double(Sidekiq::Stats) }
    let(:process)    { instance_double(Sidekiq::Process) }
    let(:queue_name) { "quest" }

    before do
      allow(Sidekiq::Stats).to receive(:new).and_return(stats)
      allow(stats).to receive(:queues).and_return([queue_name])

      allow(Sidekiq::ProcessSet).to receive(:new).and_return([process])
      allow(process).to receive(:[]).with("queues").and_return([queue_name])

      allow(ActiveRecord::Base.connection).to receive(:active?).and_return(true)
      allow(Sidekiq).to receive(:redis_info).and_return({})
    end

    context "when everything is ok" do
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
          sidekiq_processes: true,
        } }.to_json)
      end
    end

    context "there's no process for a queue" do
      before do
        allow(process).to receive(:[]).with("queues").and_return([])
      end

      it("returns 503") do
        get "/healthcheck"

        expect(response.status).to eq 503
      end

      it "sets the sidekiq queue to false" do
        get "/healthcheck"

        json_response = JSON.parse(response.body)

        expect(json_response["checks"]["sidekiq_processes"]).to eq false
      end
    end

    context "there's no Redis connection" do
      before do
        allow(Sidekiq).to receive(:redis_info).and_raise(Errno::ECONNREFUSED)
      end

      it("returns 503") do
        get "/healthcheck"

        expect(response.status).to eq 503
      end

      it "sets the sidekiq queue to false" do
        get "/healthcheck"

        json_response = JSON.parse(response.body)

        expect(json_response["checks"]).to include("redis" => false)
      end
    end

    context "there's no db connection" do
      before do
        allow(ActiveRecord::Base.connection)
          .to receive(:active?).and_return(false)
      end

      it("returns 503") do
        get "/healthcheck"

        expect(response.status).to eq 503
      end

      it "sets the sidekiq queue to false" do
        get "/healthcheck"

        json_response = JSON.parse(response.body)

        expect(json_response["checks"]).to include("database" => false)
      end
    end
  end
end
