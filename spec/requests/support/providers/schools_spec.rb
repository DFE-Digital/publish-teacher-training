# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support provider schools" do
  include DfESignInUserHelper

  let(:provider) { create(:provider) }
  let(:recruitment_cycle) { provider.recruitment_cycle }
  let(:gias_school) do
    create(
      :gias_school,
      name: "St Joseph's Catholic Primary School",
      urn: "112992",
      address1: "1 School Lane",
      town: "Leeds",
      postcode: "LS1 1AA",
    )
  end
  let(:admin) { create(:user, :admin) }

  before do
    host! URI(Settings.base_url).host
    login_user(admin)
  end

  # These pages read Provider::School, so they are exercised with a provider
  # school that has no legacy Site mirroring it.
  describe "GET /support/:recruitment_cycle_year/providers/:provider_id/schools" do
    let!(:provider_school) { create(:provider_school, provider:, gias_school:, site_code: "A") }

    it "lists the provider's schools" do
      get support_recruitment_cycle_provider_schools_path(recruitment_cycle.year, provider)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("St Joseph")
      expect(response.body).to include("Catholic Primary School")
      expect(response.body).to include("112992")
      expect(response.body).to include(support_recruitment_cycle_provider_school_path(recruitment_cycle.year, provider, provider_school.uuid))
    end
  end

  # Schools are added through search -> check. The page that posted here was
  # deleted in 8ab6a3978, which left this action behind.
  describe "POST /support/:recruitment_cycle_year/providers/:provider_id/schools" do
    it "is not routed" do
      declared = Rails.application.routes.routes.map do |route|
        [route.verb, route.defaults[:controller], route.defaults[:action]]
      end

      expect(declared).not_to include(["POST", "support/providers/schools", "create"])
    end
  end

  describe "GET /support/:recruitment_cycle_year/providers/:provider_id/schools/:uuid" do
    let!(:provider_school) { create(:provider_school, provider:, gias_school:, site_code: "A") }

    it "shows the school" do
      get support_recruitment_cycle_provider_school_path(recruitment_cycle.year, provider, provider_school.uuid)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("St Joseph")
      expect(response.body).to include("Catholic Primary School")
      expect(response.body).to include("School code")
      expect(response.body).to include("112992")
      expect(response.body).to include("1 School Lane")
    end

    it "returns not found for another provider's school" do
      other_provider_school = create(:provider_school)

      get support_recruitment_cycle_provider_school_path(recruitment_cycle.year, provider, other_provider_school.uuid)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /support/:recruitment_cycle_year/providers/:provider_id/schools/:uuid/delete" do
    let!(:provider_school) { create(:provider_school, provider:, gias_school:, site_code: "A") }
    # A provider's last school cannot be removed, so give it a spare.
    let!(:other_provider_school) { create(:provider_school, provider:) }

    it "offers to remove a school that no course uses" do
      get delete_support_recruitment_cycle_provider_school_path(recruitment_cycle.year, provider, provider_school.uuid)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("St Joseph")
      expect(response.body).to include("Remove school")
    end

    it "explains why a school in use cannot be removed" do
      course = create(:course, provider:)
      create(:course_school, course:, gias_school:, provider_school:)

      get delete_support_recruitment_cycle_provider_school_path(recruitment_cycle.year, provider, provider_school.uuid)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("is a school for courses run by #{provider.provider_name}")
    end
  end

  describe "DELETE /support/:recruitment_cycle_year/providers/:provider_id/schools/:uuid" do
    let!(:site) { create(:site, provider:, urn: gias_school.urn, code: "A", uuid: SecureRandom.uuid) }
    let!(:provider_school) do
      create(:provider_school, provider:, gias_school:, site_code: site.code, uuid: site.uuid)
    end
    let!(:other_provider_school) { create(:provider_school, provider:) }
    let!(:exempt_course) { create(:course, :with_salary, provider:, publish_without_schools_allowed: true) }

    def remove_school
      delete support_recruitment_cycle_provider_school_path(recruitment_cycle.year, provider, provider_school.uuid)
    end

    it "removes the school" do
      expect { remove_school }.to change { provider.schools.count }.by(-1)

      expect(response).to redirect_to(support_recruitment_cycle_provider_schools_path(recruitment_cycle.year, provider))
    end

    # A course that is allowed to publish without schools is served by the API
    # with all of its provider's schools as locations, so removing one changes
    # that course's payload.
    it "touches every course that is publishable without schools" do
      second_exempt_course = create(:course, :with_salary, provider:, publish_without_schools_allowed: true)

      expect { remove_school }.to(change { [exempt_course.reload.changed_at, second_exempt_course.reload.changed_at] })
    end

    it "does not touch another provider's courses" do
      other_exempt_course = create(:course, :with_salary, publish_without_schools_allowed: true)

      expect { remove_school }.not_to(change { other_exempt_course.reload.changed_at })
    end

    it "does not touch courses when the school cannot be removed" do
      course = create(:course, provider:)
      create(:course_school, course:, gias_school:, provider_school:)

      expect { remove_school }.not_to(change { exempt_course.reload.changed_at })

      expect(provider.schools).to contain_exactly(provider_school, other_provider_school)
      expect(flash[:warning]).to eq("This school could not be removed because it is used by a course")
    end

    it "does not remove the provider's last school" do
      other_provider_school.destroy!

      expect { remove_school }.not_to(change { provider.schools.count })

      expect(response).to redirect_to(delete_support_recruitment_cycle_provider_school_path(recruitment_cycle.year, provider, provider_school.uuid))
      expect(flash[:warning]).to eq("This school could not be removed because it is the provider’s only school")
    end
  end
end
