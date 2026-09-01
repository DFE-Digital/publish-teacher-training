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

      context "when the course only has canonical schools" do
        render_views

        let(:provider) { create(:provider, selectable_school: true) }
        let(:course) { create(:course, :published, provider:) }

        before { FeatureFlag.activate(:course_publishing_uses_new_school_model) }
        after { FeatureFlag.deactivate(:course_publishing_uses_new_school_model) }

        def get_placements
          get :index, params: {
            provider_code: provider.provider_code,
            course_code: course.course_code,
          }
        end

        it "lists each school's name and address with no Site or SiteStatus in play" do
          create(
            :course_school,
            course:,
            gias_school: create(:gias_school, name: "Ashfield School", address1: "12 Mill Lane", town: "Barnsley", postcode: "S70 2AB"),
          )

          get_placements

          expect(course.site_statuses).to be_empty
          expect(response.body).to include("Ashfield School")
          expect(response.body).to include("12 Mill Lane, Barnsley, S70 2AB")
        end

        it "lists a school once when the course reaches it through two provider schools" do
          gias_school = create(:gias_school, name: "Ashfield School")
          create(:course_school, course:, gias_school:, site_code: "A")
          create(:course_school, course:, gias_school:, site_code: "B")

          get_placements

          expect(response.body.scan("Ashfield School").size).to eq(1)
        end

        it "still renders the not found page when the provider is not selectable" do
          provider.update!(selectable_school: false)

          get_placements

          expect(response).to be_not_found
        end
      end
    end
  end
end
