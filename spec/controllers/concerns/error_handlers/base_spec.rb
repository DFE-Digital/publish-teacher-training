# frozen_string_literal: true

require "rails_helper"

describe "Base" do
  controller(ActionController::Base) do
    include ErrorHandlers::Base

    def error
      raise hell
    end

    def invalid_include
      raise JSONAPI::IncludeDirective::InvalidKey, "bad'include"
    end
  end

  before do
    allow(Settings).to receive(:render_json_errors).and_return(render_json_errors)

    routes.draw do
      get "error" => "anonymous#error"
      get "invalid_include" => "anonymous#invalid_include"
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
      expect(response.parsed_body).to match(
        "errors" => [
          {
            "status" => 500,
            "title" => a_string_including("ERROR"),
            "detail" => a_string_including("gone wrong"),
          },
        ],
      )
    end

    context "when the include param is invalid" do
      it "does not send the error to sentry" do
        expect(Sentry).not_to receive(:capture_exception)
        get :invalid_include
      end

      it "returns a bad request response" do
        get :invalid_include
        expect(response).to have_http_status(:bad_request)
      end

      it "returns a friendly error message" do
        get :invalid_include
        expect(response.parsed_body).to match(
          "errors" => [
            {
              "status" => 400,
              "title" => "BAD REQUEST",
              "detail" => I18n.t("jsonapi.invalid_include"),
            },
          ],
        )
      end
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
