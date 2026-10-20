# frozen_string_literal: true

require "rails_helper"

describe "heartbeat requests" do
  describe "GET /ping" do
    it "returns PONG" do
      get "/ping"

      expect(response.body).to eq "PONG"
    end
  end

  describe "GET /healthcheck" do
    def register_solid_queue_process(kind, last_heartbeat_at: Time.current)
      SolidQueue::Process.create!(
        kind:,
        name: "#{kind.downcase}-#{SecureRandom.hex(4)}",
        pid: 1,
        hostname: "solid-queue-worker",
        last_heartbeat_at:,
      )
    end

    before do
      register_solid_queue_process("Worker")
      register_solid_queue_process("Dispatcher")

      allow(ActiveRecord::Base.connection).to receive(:active?).and_return(true)
    end

    context "when everything is ok" do
      it "returns HTTP success" do
        get "/healthcheck"

        expect(response).to have_http_status(:ok)
      end

      it "returns JSON" do
        get "/healthcheck"
        expect(response.content_type).to eq("application/json; charset=utf-8")
      end

      it "returns the expected response report" do
        get "/healthcheck"

        expect(response.body).to eq({ checks: {
          database: true,
          solid_queue_processes: true,
        } }.to_json)
      end
    end

    context "when no Solid Queue worker has a recent heartbeat" do
      before do
        SolidQueue::Process.where(kind: "Worker").update_all(last_heartbeat_at: 10.minutes.ago)
      end

      it("returns 503") do
        get "/healthcheck"

        expect(response).to have_http_status(:service_unavailable)
      end

      it "sets the Solid Queue check to false" do
        get "/healthcheck"

        expect(response.parsed_body["checks"]["solid_queue_processes"]).to be false
      end
    end

    context "when the environment has recurring tasks" do
      before do
        allow(Rails.application).to receive(:config_for).and_call_original
        allow(Rails.application).to receive(:config_for).with(:recurring).and_return({ save_statistic: {} })
      end

      it "needs a live scheduler" do
        get "/healthcheck"

        expect(response.parsed_body["checks"]["solid_queue_processes"]).to be false

        register_solid_queue_process("Scheduler")
        get "/healthcheck"

        expect(response.parsed_body["checks"]["solid_queue_processes"]).to be true
      end

      it "does not need a scheduler when recurring tasks are skipped" do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("SOLID_QUEUE_SKIP_RECURRING").and_return("true")

        get "/healthcheck"

        expect(response.parsed_body["checks"]["solid_queue_processes"]).to be true
      end
    end

    context "there's no db connection" do
      before do
        allow(ActiveRecord::Base.connection)
          .to receive(:active?).and_return(false)
      end

      it("returns 503") do
        get "/healthcheck"

        expect(response).to have_http_status(:service_unavailable)
      end

      it "sets the database check to false" do
        get "/healthcheck"

        json_response = response.parsed_body

        expect(json_response["checks"]).to include("database" => false)
      end
    end
  end

  describe "GET /sha" do
    it "returns the sha from the file COMMIT_SHA" do
      ENV["COMMIT_SHA"] = "my-commit-sha"

      get "/sha"

      expect(response.body).to eq '{"sha":"my-commit-sha"}'
    end
  end
end
