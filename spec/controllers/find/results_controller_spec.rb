# frozen_string_literal: true

require "rails_helper"

module Find
  describe ResultsController do
    before do
      Timecop.travel(Find::CycleTimetable.mid_cycle)
    end

    describe "GET #index" do
      context "when results authentication is required" do
        before do
          FeatureFlag.activate(:require_authentication_for_find_results)
          request.host = URI(Settings.find_url).host
        end

        it "redirects an unauthenticated candidate before starting the search" do
          expect(Geolocation::Address).not_to receive(:query)

          get :index, params: { location: "Manchester", subjects: %w[F3], order: "distance" }

          expect(response).to redirect_to(find_root_path)
          expect(session[Find::Authentication::RETURN_TO_AFTER_AUTHENTICATING_SESSION_KEY]["path"]).to eq(request.fullpath)
          expect(flash[:sign_in_reason]).to eq(:search_results)
        end

        it "falls back to the results path when the requested URL is too large for the session" do
          get :index, params: { location: "x" * 3.kilobytes }

          expect(session[Find::Authentication::RETURN_TO_AFTER_AUTHENTICATING_SESSION_KEY]["path"]).to eq("/results")
        end

        it "allows an authenticated candidate to search" do
          candidate_session = create(:session)
          cookies.signed[Settings.cookies.candidate_session.name] = candidate_session.session_key

          get :index

          expect(response).to have_http_status(:ok)
        end
      end

      it "does not raise when provider.provider_name is passed as a parameter" do
        expect {
          get :index, params: { "provider.provider_name" => "Some Provider" }
        }.not_to raise_error
      end

      %w[age_group degree_required sortby university_degree_status lq].each do |legacy_param|
        it "does not raise when legacy param #{legacy_param} is passed as a parameter" do
          expect {
            get :index, params: { legacy_param => "some_value" }
          }.not_to raise_error
        end
      end

      it "does not raise when legacy param study_type is passed as a parameter" do
        expect {
          get :index, params: { study_type: %w[full_time] }
        }.not_to raise_error
      end

      it "does not raise when legacy param qualification is passed as a parameter" do
        expect {
          get :index, params: { qualification: %w[qts] }
        }.not_to raise_error
      end

      it "does not raise when location is passed as a hash instead of a string" do
        expect {
          get :index, params: { location: { foo: "bar" } }
        }.not_to raise_error
      end
    end
  end
end
