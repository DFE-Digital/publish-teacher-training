# frozen_string_literal: true

require "rails_helper"

module Find
  module Candidates
    RSpec.describe SavedCoursesController, service: :find, type: :controller do
      before do
        FeatureFlag.activate(:candidate_accounts)
        request.host = URI(Settings.find_url).host
      end

      let(:course) do
        create(
          :course,
          :with_full_time_sites,
          :secondary,
          :with_special_education_needs,
          :published,
          :open,
          provider: build(:provider, provider_name: "York university", provider_code: "RO1"),
        )
      end

      describe "GET #sign_in" do
        it "does not call SaveCourseService" do
          expect(Find::SaveCourseService).not_to receive(:call)

          get :sign_in, params: { course_id: course.id }

          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
