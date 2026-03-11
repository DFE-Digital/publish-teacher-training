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
    end
  end
end
