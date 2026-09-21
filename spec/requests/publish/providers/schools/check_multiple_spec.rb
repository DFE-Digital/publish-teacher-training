# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publish provider multiple schools check", service: :publish do
  include DfESignInUserHelper

  let(:user) { create(:user, :with_provider) }
  let(:provider) { user.providers.first }
  let(:recruitment_cycle) { provider.recruitment_cycle }
  let(:gias_schools) do
    [
      create(:gias_school, name: "St Joseph's Catholic Primary School", urn: "112992"),
      create(:gias_school, name: "Bramble Hill Academy", urn: "112993"),
    ]
  end

  before { login_user(user) }

  def stash_urns(urns)
    URNForm.new(provider, params: { values: urns }).stash
  end

  def add_schools(urns = gias_schools.map(&:urn))
    stash_urns(urns)

    put publish_provider_recruitment_cycle_schools_multiple_check_path(provider.provider_code, recruitment_cycle.year)
  end

  describe "PUT /publish/organisations/:provider_code/:recruitment_cycle_year/schools/multiple/check" do
    let!(:exempt_course) { create(:course, :with_salary, provider:, publish_without_schools_allowed: true) }

    it "adds the schools to the provider" do
      expect { add_schools }.to change { provider.schools.count }.by(2)

      expect(response).to redirect_to(publish_provider_recruitment_cycle_schools_path(provider.provider_code, recruitment_cycle.year))
      expect(provider.schools.map(&:gias_school)).to match_array(gias_schools)
    end

    # The API serves every one of the provider's schools as the locations of a
    # course that is allowed to publish without schools, so adding schools
    # changes that course's payload. Bumping changed_at is what tells API
    # consumers to re-fetch it.
    it "touches courses that are publishable without schools" do
      expect { add_schools }.to(change { exempt_course.reload.changed_at })
    end

    it "touches every course that is publishable without schools" do
      second_exempt_course = create(:course, :with_salary, provider:, publish_without_schools_allowed: true)

      expect { add_schools }.to(change { [exempt_course.reload.changed_at, second_exempt_course.reload.changed_at] })

      expect(exempt_course.changed_at).to be > exempt_course.updated_at
      expect(second_exempt_course.changed_at).to be > second_exempt_course.updated_at
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
      expect(flash[:success]).to be_nil
    end

    it "adds a school GIAS holds no street for" do
      no_street = create(:gias_school, urn: "112994", address1: "", address2: "Holbury", town: "Southampton")

      expect { add_schools([no_street.urn]) }.to change { provider.schools.count }.by(1)
    end

    it "adds the schools it can and names the ones it cannot" do
      no_address = create(:gias_school, urn: "112994", address1: "", address2: "", address3: "", town: "", postcode: "")

      expect { add_schools(gias_schools.map(&:urn) + [no_address.urn]) }
        .to change { provider.schools.count }.by(2)
        .and(change { exempt_course.reload.changed_at })

      expect(flash[:warning]).to eq(
        "title" => "1 school could not be added",
        "body" => "2 schools added. The address we hold for 112994 is incomplete. " \
                  "Ask the school to update its details on Get Information About Schools (GIAS).",
      )
    end

    it "names every school when it can add none of them" do
      no_address = create(:gias_school, urn: "112994", address1: "", address2: "", address3: "", town: "", postcode: "")

      expect { add_schools([no_address.urn]) }.not_to(change { provider.schools.count })

      expect(flash[:warning]).to eq(
        "title" => "1 school could not be added",
        "body" => "The address we hold for 112994 is incomplete. " \
                  "Ask the school to update its details on Get Information About Schools (GIAS).",
      )
    end
  end
end
