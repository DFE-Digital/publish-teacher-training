# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::Public::V1::Providers::Courses::LocationsController do
  let(:course) { create(:course) }
  let(:provider) { course.provider }

  describe "#index" do
    context "when a course does not have any locations" do
      before do
        get :index, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          course_code: course.course_code,
        }
      end

      it "returns empty array of data" do
        expect(json_response["data"]).to eql([])
      end
    end

    context "when a course has locations" do
      before do
        course.sites << build_list(:site, 2, provider:)

        get :index, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          course_code: course.course_code,
        }
      end

      it "returns the correct number of locations" do
        expect(json_response["data"].size).to be(2)
      end

      context "with includes" do
        before do
          get :index, params: {
            recruitment_cycle_year: provider.recruitment_cycle.year,
            provider_code: provider.provider_code,
            course_code: course.course_code,
            include: "recruitment_cycle,provider,course,location_status",
          }
        end

        it "returns the requested associated data in the response" do
          relationships = json_response["data"][0]["relationships"]

          recruitment_cycle_id = relationships.dig("recruitment_cycle", "data", "id").to_i
          provider_id = relationships.dig("provider", "data", "id").to_i
          course_id = relationships.dig("course", "data", "id").to_i
          location_status_id = relationships.dig("location_status", "data", "id").to_i

          expect(json_response["data"][0]["relationships"].keys.sort).to eq(
            %w[course location_status provider recruitment_cycle],
          )

          expect(recruitment_cycle_id).to eq(provider.recruitment_cycle.id)
          expect(provider_id).to eq(provider.id)
          expect(course_id).to eq(course.id)
          expect(location_status_id).to eq(course.site_statuses.first.id)
        end
      end
    end
  end

  context "when selecting locations by recruitment cycle" do
    let(:provider) { create(:provider, recruitment_cycle: find_or_create(:recruitment_cycle, year: Settings.schools_remodel_cycle_year + 1)) }
    let(:course) { create(:course, provider:) }

    context "when the recruitment cycle is not after the remodel cutover year" do
      let(:provider) { create(:provider, recruitment_cycle: find_or_create(:recruitment_cycle, year: Settings.schools_remodel_cycle_year)) }
      let(:course) { create(:course, provider:) }

      before do
        course.sites << build_list(:site, 2, provider:)

        get :index, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          course_code: course.course_code,
        }
      end

      it "returns the legacy sites as locations" do
        expect(json_response["data"].size).to be(2)
      end
    end

    context "when a course does not have any schools" do
      before do
        get :index, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          course_code: course.course_code,
        }
      end

      it "returns empty array of data" do
        expect(json_response["data"]).to eql([])
      end
    end

    context "when a course has no schools but is exempt from needing them" do
      let(:course) { create(:course, :with_salary, provider:, publish_without_schools_allowed: true) }

      before do
        create_list(:provider_school, 2, provider:)

        get :index, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          course_code: course.course_code,
        }
      end

      it "returns the provider's schools as locations" do
        expect(json_response["data"].size).to be(2)
      end

      it "flags in the meta that the locations are not the course's own schools" do
        expect(json_response["meta"]).to eq("has_course_schools" => false)
      end
    end

    context "when a course has its own schools and is exempt from needing them" do
      let(:course) { create(:course, :with_salary, provider:, publish_without_schools_allowed: true) }

      before do
        create(:course_school, course:)
        create_list(:provider_school, 3, provider:)

        get :index, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          course_code: course.course_code,
        }
      end

      it "returns only the course's own schools, not the provider fallback" do
        expect(json_response["data"].size).to be(1)
      end

      it "flags in the meta that the locations are the course's own schools" do
        expect(json_response["meta"]).to eq("has_course_schools" => true)
      end
    end

    context "when a fee-paying course has one course school and is exempt from needing them" do
      let(:course) { create(:course, :fee, provider:, publish_without_schools_allowed: true) }

      before do
        create(:course_school, course:)
        create_list(:provider_school, 2, provider:)

        get :index, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          course_code: course.course_code,
        }
      end

      it "returns the course schools" do
        expect(json_response["data"].size).to be(1)
      end

      it "flags in the meta that the locations are the course's own schools" do
        expect(json_response["meta"]).to eq("has_course_schools" => true)
      end
    end

    context "when a fee-paying course has no schools and is exempt from needing them" do
      let(:course) { create(:course, :fee, provider:, publish_without_schools_allowed: true) }

      before do
        create_list(:provider_school, 2, provider:)

        get :index, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          course_code: course.course_code,
        }
      end

      it "returns the provider fallback" do
        expect(json_response["data"].size).to be(2)
      end

      it "flags in the meta says that the locations are the providers schools" do
        expect(json_response["meta"]).to eq("has_course_schools" => false)
      end
    end

    context "when a course has schools" do
      let(:course) { create(:course, study_mode: "full_time", provider:) }
      let(:school) { create(:course_school, course:, site_code: "-") }

      before do
        create(:course_school, course:)
        school

        get :index, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          course_code: course.course_code,
        }
      end

      it "returns the schools as locations" do
        expect(json_response["data"].size).to be(2)
        expect(json_response["data"].map { |location| location["type"] }.uniq).to eq(%w[locations])
      end

      it "serializes the school's attributes from its gias school" do
        location = json_response["data"].find { |data| data["attributes"]["code"] == school.site_code }
        attributes = location["attributes"]

        expect(attributes["name"]).to eq("#{school.gias_school.name} (Main site)")
        expect(attributes["urn"]).to eq(school.gias_school.urn)
        expect(attributes["postcode"]).to eq(school.gias_school.postcode)
        expect(attributes["region_code"]).to eq(school.gias_school.region_code)
      end

      context "when a school's gias region code differs from the api region set" do
        let(:school) { create(:course_school, course:, gias_school: create(:gias_school, region_code: :east_of_england)) }

        it "maps the gias region code to the api region code" do
          location = json_response["data"].find { |data| data["attributes"]["code"] == school.site_code }

          expect(location["attributes"]["region_code"]).to eq("eastern")
        end
      end

      context "with includes" do
        before do
          get :index, params: {
            recruitment_cycle_year: provider.recruitment_cycle.year,
            provider_code: provider.provider_code,
            course_code: course.course_code,
            include: "recruitment_cycle,provider,course,location_status",
          }
        end

        it "returns the requested associated data in the response" do
          relationships = json_response["data"][0]["relationships"]

          recruitment_cycle_id = relationships.dig("recruitment_cycle", "data", "id").to_i
          provider_id = relationships.dig("provider", "data", "id").to_i
          course_id = relationships.dig("course", "data", "id").to_i

          expect(relationships.keys.sort).to eq(
            %w[course location_status provider recruitment_cycle],
          )

          expect(recruitment_cycle_id).to eq(provider.recruitment_cycle.id)
          expect(provider_id).to eq(provider.id)
          expect(course_id).to eq(course.id)
        end

        it "returns a synthetic running, published, with-vacancies location status" do
          location_status = json_response["included"].find { |resource| resource["type"] == "location_statuses" }

          expect(location_status["attributes"]).to eq(
            "publish" => "published",
            "status" => "running",
            "vacancy_status" => "full_time_vacancies",
            "has_vacancies" => true,
          )
        end
      end
    end
  end

  context "when the feature flag is disabled and the cycle is not after the remodel cutover year" do
    let(:provider) { create(:provider, recruitment_cycle: find_or_create(:recruitment_cycle, year: Settings.schools_remodel_cycle_year)) }
    let(:course) { create(:course, provider:) }

    before do
      course.sites << build_list(:site, 2, provider:)

      get :index, params: {
        recruitment_cycle_year: provider.recruitment_cycle.year,
        provider_code: provider.provider_code,
        course_code: course.course_code,
      }
    end

    it "returns the legacy sites as locations" do
      expect(json_response["data"].size).to be(2)
    end
  end

  describe "recruitment cycle" do
    context 'when "current" is specified as the recruitment cycle' do
      before do
        course.sites << build_list(:site, 2, provider:)

        get :index, params: {
          recruitment_cycle_year: "current",
          provider_code: provider.provider_code,
          course_code: course.course_code,
        }
      end

      it "returns the correct number of locations" do
        expect(json_response["data"].size).to be(2)
      end
    end

    context "when a non-existent recruitment cycle is specified" do
      before do
        course.sites << build_list(:site, 2, provider:)

        get :index, params: {
          recruitment_cycle_year: "1066",
          provider_code: provider.provider_code,
          course_code: course.course_code,
        }
      end

      it "returns locations for current recruitment cycle year" do
        expect(json_response["data"].size).to be(2)
      end
    end
  end
end
