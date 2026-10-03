# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support provider school checks" do
  include DfESignInUserHelper

  let(:provider) { create(:provider) }
  let(:recruitment_cycle) { provider.recruitment_cycle }
  let(:gias_school) { create(:gias_school) }
  let(:admin) { create(:user, :admin) }

  before do
    host! URI(Settings.base_url).host
    login_user(admin)
  end

  def add_school
    put support_recruitment_cycle_provider_schools_check_path(
      recruitment_cycle.year,
      provider,
      school_id: gias_school.id,
    )
  end

  describe "touching courses that are publishable without schools" do
    let!(:exempt_course) { create(:course, :with_salary, provider:, publish_without_schools_allowed: true) }

    # The API serves every one of the provider's schools as the locations of a
    # course that is allowed to publish without schools, so adding a school
    # changes that course's payload. Bumping changed_at is what tells API
    # consumers to re-fetch it.
    it "touches every course that is publishable without schools" do
      second_exempt_course = create(:course, :with_salary, provider:, publish_without_schools_allowed: true)

      expect { add_school }.to(change { [exempt_course.reload.changed_at, second_exempt_course.reload.changed_at] })

      expect(provider.schools.count).to eq(1)
    end

    it "does not touch courses that have their own schools" do
      school_course = create(:course, :with_2_schools, provider:)

      expect { add_school }.not_to(change { school_course.reload.changed_at })
    end

    it "does not touch another provider's courses" do
      other_exempt_course = create(:course, :with_salary, publish_without_schools_allowed: true)

      expect { add_school }.not_to(change { other_exempt_course.reload.changed_at })
    end

    it "does not touch courses when the school is not added" do
      allow(ProviderSchools::Creator).to receive(:call).and_raise(StandardError, "provider school failed")

      expect {
        expect { add_school }.to raise_error(StandardError, "provider school failed")
      }.not_to(change { exempt_course.reload.changed_at })
    end
  end

  it "adds only the provider school, without a legacy site" do
    expect { add_school }
      .to change { provider.schools.where(gias_school:).count }.by(1)
      .and(not_change { provider.sites.count })

    expect(response).to redirect_to(support_recruitment_cycle_provider_schools_path(recruitment_cycle.year, provider))
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
end
