# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support provider multiple school checks" do
  include DfESignInUserHelper

  let(:provider) { create(:provider) }
  let(:recruitment_cycle) { provider.recruitment_cycle }
  let(:gias_schools) do
    [
      create(:gias_school, urn: "112992"),
      create(:gias_school, urn: "112993"),
    ]
  end
  let(:admin) { create(:user, :admin) }

  before do
    host! URI(Settings.base_url).host
    login_user(admin)
  end

  def add_schools(urns = gias_schools.map(&:urn))
    URNForm.new(provider, params: { values: urns }).stash

    put support_recruitment_cycle_provider_schools_multiple_check_path(recruitment_cycle.year, provider)
  end

  describe "GET /support/:recruitment_cycle_year/providers/:provider_id/schools/multiple/check" do
    let(:gias_school) do
      create(
        :gias_school,
        name: "St Joseph's Catholic Primary School",
        urn: "112992",
        address1: "1 School Lane",
        address2: "Building A",
        address3: "Quarter B",
        town: "Leeds",
        county: "West Yorkshire",
        postcode: "LS1 1AA",
      )
    end

    def check_schools(urns)
      URNForm.new(provider, params: { values: urns }).stash

      get support_recruitment_cycle_provider_schools_multiple_check_path(recruitment_cycle.year, provider)
    end

    it "previews each school being added" do
      check_schools([gias_school.urn])

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("St Joseph")
      expect(response.body).to include("Catholic Primary School")
      expect(response.body).to include("112992")
      expect(response.body).to include("1 School Lane")
      expect(response.body).to include("Building A")
      expect(response.body).to include("Quarter B")
      expect(response.body).to include("Leeds")
      expect(response.body).to include("West Yorkshire")
      expect(response.body).to include("LS1 1AA")
    end

    it "warns about a urn that matches no school" do
      check_schools(%w[999999])

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("St Joseph")
    end
  end

  describe "PUT /support/:recruitment_cycle_year/providers/:provider_id/schools/multiple/check" do
    let!(:exempt_course) { create(:course, :with_salary, provider:, publish_without_schools_allowed: true) }

    it "adds the schools to the provider" do
      expect { add_schools }.to change { provider.schools.count }.by(2)

      expect(response).to redirect_to(support_recruitment_cycle_provider_schools_path(recruitment_cycle.year, provider))
      expect(provider.schools.map(&:gias_school)).to match_array(gias_schools)
    end

    # The API serves every one of the provider's schools as the locations of a
    # course that is allowed to publish without schools, so adding schools
    # changes that course's payload. Bumping changed_at is what tells API
    # consumers to re-fetch it.
    it "touches every course that is publishable without schools" do
      second_exempt_course = create(:course, :with_salary, provider:, publish_without_schools_allowed: true)

      expect { add_schools }.to(change { [exempt_course.reload.changed_at, second_exempt_course.reload.changed_at] })
    end

    it "sweeps the courses once, not once per school added" do
      allow(Provider::School).to receive(:touch_no_school_courses_for).and_call_original

      add_schools

      expect(Provider::School).to have_received(:touch_no_school_courses_for).once
    end

    it "does not touch courses that have their own schools" do
      school_course = create(:course, :with_2_schools, provider:)

      expect { add_schools }.not_to(change { school_course.reload.changed_at })
    end

    it "does not touch another provider's courses" do
      other_exempt_course = create(:course, :with_salary, publish_without_schools_allowed: true)

      expect { add_schools }.not_to(change { other_exempt_course.reload.changed_at })
    end

    it "does not touch anything when no school is added" do
      expect { add_schools(%w[999999]) }.not_to(change { exempt_course.reload.changed_at })

      expect(provider.schools.count).to be_zero
    end
  end
end
