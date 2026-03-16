# frozen_string_literal: true

require "rails_helper"

module Find
  describe ResultsController do
    before do
      Timecop.travel(Find::CycleTimetable.mid_cycle)
    end

    describe "GET #index" do
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
