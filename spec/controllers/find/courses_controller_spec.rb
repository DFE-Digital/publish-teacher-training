# frozen_string_literal: true

require "rails_helper"

module Find
  describe CoursesController do
    before do
      Timecop.travel(Find::CycleTimetable.mid_cycle)
    end

    let(:user) { create(:user, :with_provider) }
    let(:provider) { user.providers.first }

    let(:course) do
      create(
        :course,
        :with_gcse_equivalency,
        enrichments: [build(:course_enrichment, :initial_draft)],
        sites: [create(:site, location_name: "location 1")],
        provider:,
      )
    end

    describe "#apply" do
      it "redirects" do
        expect(Rails.logger).to receive(:info).with("Course apply conversion. Provider: #{course.provider.provider_code}. Course: #{course.course_code}").once
        expect(Rails.logger).to receive(:info)

        get :apply, params: {
          provider_code: provider.provider_code,
          course_code: course.course_code,
        }

        expect(response).to redirect_to("https://www.apply-for-teacher-training.service.gov.uk/candidate/apply?providerCode=#{provider.provider_code}&courseCode=#{course.course_code}")
      end

      it "redirects when downcase provider and course code" do
        get :apply, params: {
          provider_code: provider.provider_code.downcase,
          course_code: course.course_code.downcase,
        }

        expect(response).to redirect_to("https://www.apply-for-teacher-training.service.gov.uk/candidate/apply?providerCode=#{provider.provider_code}&courseCode=#{course.course_code}")
      end

      it "raises a not found error when the provider does not exist" do
        get :apply, params: {
          provider_code: "ABCD",
          course_code: course.course_code.downcase,
        }

        expect(response).to be_not_found
      end

      it "raises a not found error when the course does not exist" do
        get :apply, params: {
          provider_code: provider.provider_code,
          course_code: "ABCD",
        }

        expect(response).to be_not_found
      end
    end

    describe "#show" do
      it "renders the not found page" do
        get :show, params: {
          provider_code: "ABC",
          course_code: "123",
        }

        expect(response).to be_not_found
      end

      context "when a location param is given but geocoding returns no coordinates" do
        let(:published_course) do
          create(
            :course,
            enrichments: [build(:course_enrichment, :published)],
            sites: [create(:site, latitude: 51.5, longitude: -0.1)],
            provider:,
          )
        end

        before do
          allow(Geolocation::Address).to receive(:query).and_return(
            Geolocation::Address.new(latitude: nil, longitude: nil, formatted_address: nil),
          )
        end

        it "does not raise a TypeError from Float(nil)" do
          expect {
            get :show, params: {
              provider_code: provider.provider_code,
              course_code: published_course.course_code,
              location: "somewhere unresolvable",
            }
          }.not_to raise_error
        end
      end

      context "when the course only has canonical schools" do
        render_views

        let(:london) { build(:location, :london) }
        let(:canary_wharf) { build(:location, :canary_wharf) }

        let(:published_course) do
          create(:course, enrichments: [build(:course_enrichment, :published)], provider:)
        end

        before do
          FeatureFlag.activate(:course_publishing_uses_new_school_model)
          allow(Geolocation::Address).to receive(:query).and_return(
            Geolocation::Address.new(latitude: london.latitude, longitude: london.longitude, formatted_address: "London"),
          )
        end

        after { FeatureFlag.deactivate(:course_publishing_uses_new_school_model) }

        def get_show_from_london
          get :show, params: {
            provider_code: provider.provider_code,
            course_code: published_course.course_code,
            location: "London",
          }
        end

        it "measures the distance from the nearest GIAS school, with no Site or SiteStatus in play" do
          create(
            :course_school,
            course: published_course,
            gias_school: create(:gias_school, latitude: canary_wharf.latitude, longitude: canary_wharf.longitude),
          )

          get_show_from_london

          expect(published_course.site_statuses).to be_empty
          expect(response).to have_http_status(:ok)
          expect(controller.view_assigns["distance_from_location"]).to eq(5)
        end

        it "renders without a distance when the course has no geocoded school" do
          create(:course_school, course: published_course, gias_school: create(:gias_school))

          get_show_from_london

          expect(response).to have_http_status(:ok)
          expect(controller.view_assigns["distance_from_location"]).to be_nil
        end
      end
    end
  end
end
