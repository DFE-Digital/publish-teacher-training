require "rails_helper"

describe ErrorHandlers::Base, type: :controller do
  controller(ActionController::Base) do
    include ErrorHandlers::Base

    def error
      raise hell
    end
  end

  before do
    allow(Settings).to receive(:render_json_errors).and_return(render_json_errors)

    routes.draw do
      get "error" => "anonymous#error"
    end
  end

  context "when json error reporting is enabled" do
    let(:render_json_errors) { true }

    it "sends the error to sentry" do
      expect(Sentry).to receive(:capture_exception).with(NameError)
      get :error
    end

    it "renders some nice json" do
      get :error
      expect(response.content_type).to include "application/json"
      expect(JSON.parse(response.body)).to match(
        "errors" => [
          "status" => 500,
          "title" => a_string_including("ERROR"),
          "detail" => a_string_including("gone wrong"),
        ],
      )
    end
  end

  context "when json error reporting is disabled" do
    let(:render_json_errors) { false }

    # Sentry will capure and report this in middleware (which isn't included in controller tests)
    it "doesn't swallow the error" do
      expect { get :error }.to raise_error(NameError)
    end
  end
end
