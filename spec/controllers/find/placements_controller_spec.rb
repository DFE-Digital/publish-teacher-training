# frozen_string_literal: true

require "rails_helper"

module Find
  describe PlacementsController do
    before do
      Timecop.travel(Find::CycleTimetable.mid_cycle)
    end

    describe "#placements" do
      context "when provider is not pressent" do
        it "renders the not found page" do
          get :index, params: {
            provider_code: "ABC",
            course_code: "123",
          }

          expect(response).to be_not_found
        end
      end

      context "when provider sets school_placement as not selectable" do
        it "renders the not found page" do
          provider = create(:provider, selectable_school: false)
          course = create(:course, :published, provider:)

          get :index, params: {
            provider_code: provider.provider_code,
            course_code: course.course_code,
          }

          expect(response).to be_not_found
        end
      end

      context "when course is not published" do
        it "renders the not found page" do
          provider = create(:provider)
          course = create(:course, provider:)

          get :index, params: {
            provider_code: provider.provider_code,
            course_code: course.course_code,
          }

          expect(response).to be_not_found
        end
      end

      context "when course is published and school placement is selectable" do
        it "respond successfully" do
          provider = create(:provider, selectable_school: true)
          course = create(:course, :published, provider:)

          get :index, params: {
            provider_code: provider.provider_code,
            course_code: course.course_code,
          }

          expect(response).to have_http_status(:success)
        end
      end
    end
  end
end
