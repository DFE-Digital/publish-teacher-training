# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publish provider schools check", service: :publish do
  include DfESignInUserHelper

  let(:user) { create(:user, :with_provider) }
  let(:provider) { user.providers.first }
  let(:recruitment_cycle) { provider.recruitment_cycle }
  let(:gias_school) { create(:gias_school, name: "St Joseph's Catholic Primary School", urn: "112992") }

  before { login_user(user) }

  def add_school
    put publish_provider_recruitment_cycle_schools_check_path(provider.provider_code, recruitment_cycle.year, school_id: gias_school.id)
  end

  describe "PUT /publish/organisations/:provider_code/:recruitment_cycle_year/schools/check" do
    let!(:exempt_course) { create(:course, :with_salary, provider:, publish_without_schools_allowed: true) }

    it "adds only the provider school, without a legacy site" do
      expect { add_school }
        .to change { provider.schools.where(gias_school:).count }.by(1)
        .and(not_change { provider.sites.count })

      expect(response).to redirect_to(publish_provider_recruitment_cycle_schools_path(provider.provider_code, recruitment_cycle.year))
    end

    it "does not add a school the provider already has" do
      create(:provider_school, provider:, gias_school:)

      expect { add_school }.not_to(change { provider.schools.count })

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("This school has already been added")
    end

    it "does not add a school with an incomplete address" do
      gias_school.update!(address1: "", address2: "", address3: "", town: "")

      expect { add_school }.not_to(change { provider.schools.count })

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("The address we hold for this school is incomplete")
    end

    # The API serves every one of the provider's schools as the locations of a
    # course that is allowed to publish without schools, so adding a school
    # changes that course's payload. Bumping changed_at is what tells API
    # consumers to re-fetch it.
    it "touches courses that are publishable without schools" do
      expect { add_school }.to(change { exempt_course.reload.changed_at })
    end

    it "does not touch courses that have their own schools" do
      school_course = create(:course, :with_2_schools, provider:)

      expect { add_school }.not_to(change { school_course.reload.changed_at })
    end

    it "does not touch another provider's courses" do
      other_exempt_course = create(:course, :with_salary, publish_without_schools_allowed: true)

      expect { add_school }.not_to(change { other_exempt_course.reload.changed_at })
    end

    it "touches every course that is publishable without schools" do
      second_exempt_course = create(:course, :with_salary, provider:, publish_without_schools_allowed: true)

      expect { add_school }.to(change { [exempt_course.reload.changed_at, second_exempt_course.reload.changed_at] })

      expect(exempt_course.changed_at).to be > exempt_course.updated_at
      expect(second_exempt_course.changed_at).to be > second_exempt_course.updated_at
    end
  end
end
