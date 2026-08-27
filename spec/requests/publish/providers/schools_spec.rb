# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publish provider school show page", service: :publish do
  include DfESignInUserHelper

  let(:remodel_cycle_year) { Settings.schools_remodel_cycle_year }
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

  before do
    allow(Settings).to receive(:schools_remodel_cycle_year).and_return(remodel_cycle_year)
  end

  def login_provider_user(provider)
    login_user(create(:user, providers: [provider]))
  end

  describe "GET /publish/organisations/:provider_code/:recruitment_cycle_year/schools" do
    context "when the provider is before the schools remodel cycle" do
      let(:recruitment_cycle) { find_or_create(:recruitment_cycle, year: remodel_cycle_year - 1) }
      let(:provider) { create(:provider, recruitment_cycle:) }
      let!(:site) { create(:site, provider:, urn: gias_school.urn, code: "A", uuid: SecureRandom.uuid) }
      let!(:provider_school) do
        create(:provider_school, provider:, gias_school:, site_code: site.code, uuid: site.uuid)
      end

      before { login_provider_user(provider) }

      it "lists provider schools from the new model" do
        get publish_provider_recruitment_cycle_schools_path(provider.provider_code, recruitment_cycle.year)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("St Joseph")
        expect(response.body).to include("Catholic Primary School")
        expect(response.body).to include(publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, provider_school.uuid))
      end
    end

    context "when the provider is in the schools remodel cycle" do
      let(:recruitment_cycle) { find_or_create(:recruitment_cycle, year: remodel_cycle_year) }
      let(:provider) { create(:provider, recruitment_cycle:) }
      let!(:site) { create(:site, provider:, urn: gias_school.urn, code: "A", uuid: SecureRandom.uuid) }
      let!(:provider_school) do
        create(:provider_school, provider:, gias_school:, site_code: site.code, uuid: site.uuid)
      end

      before { login_provider_user(provider) }

      it "lists provider schools resolved from the new model" do
        get publish_provider_recruitment_cycle_schools_path(provider.provider_code, recruitment_cycle.year)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("St Joseph")
        expect(response.body).to include("Catholic Primary School")
        expect(response.body).to include("1 School Lane")
        expect(response.body).to include("0 courses")
        expect(response.body).to include("Number of courses attached")
        expect(response.body).to include("Remove school")
        expect(response.body).not_to include("School code")
        expect(response.body).not_to include("112992")
        expect(response.body).to include(publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, provider_school.uuid))
        expect(response.body).to include(delete_publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, provider_school.uuid))
        expect(response.parsed_body.at_css(".remove a").text.squish).to eq("Remove school St Joseph's Catholic Primary School")
      end

      it "shows how many kept courses are attached to each school" do
        kept_course = create(:course, provider:)
        discarded_course = create(:course, provider:)
        create(:course_school, course: kept_course, provider_school:, gias_school:)
        create(:course_school, course: discarded_course, provider_school:, gias_school:)
        discarded_course.discard

        get publish_provider_recruitment_cycle_schools_path(provider.provider_code, recruitment_cycle.year)

        expect(response.body).to include("1 course")
        expect(response.body).not_to include("2 courses")
      end
    end
  end

  describe "GET /publish/organisations/:provider_code/:recruitment_cycle_year/schools/:uuid" do
    context "when the provider is in the schools remodel cycle" do
      let(:recruitment_cycle) { find_or_create(:recruitment_cycle, year: remodel_cycle_year) }
      let(:provider) { create(:provider, recruitment_cycle:) }
      let!(:site) { create(:site, provider:, urn: gias_school.urn, code: "A", uuid: SecureRandom.uuid) }
      let!(:provider_school) do
        create(:provider_school, provider:, gias_school:, site_code: site.code, uuid: site.uuid)
      end

      before { login_provider_user(provider) }

      it "displays the provider school resolved from the legacy site uuid" do
        get publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, site.uuid)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("St Joseph")
        expect(response.body).to include("Catholic Primary School")
        expect(response.body).to include("1 School Lane, Building A, Quarter B, Leeds, West Yorkshire, LS1 1AA")
        expect(response.body).to include("URN: 112992")
        expect(response.body).to include("This school is not attached to any courses.")
        expect(response.body).to include("Remove #{provider_school.decorate.location_name} from your account")
        expect(response.body).not_to include("School code")
        expect(response.body).not_to include("govuk-summary-list")
        expect(response.body).not_to include("govuk-table")
      end

      it "returns not found when the provider school does not exist" do
        provider_school.destroy!

        get publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, site.uuid)

        expect(response).to have_http_status(:not_found)
      end

      it "returns not found for another provider's school" do
        other_provider_school = create(:provider_school)

        get publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, other_provider_school.uuid)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the provider is after the schools remodel cycle" do
      let(:recruitment_cycle) { find_or_create(:recruitment_cycle, year: remodel_cycle_year + 1) }
      let(:provider) { create(:provider, recruitment_cycle:) }
      let!(:provider_school) { create(:provider_school, provider:, gias_school:, site_code: "B") }

      before { login_provider_user(provider) }

      it "displays the provider school" do
        get publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, provider_school.uuid)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("St Joseph")
        expect(response.body).to include("Catholic Primary School")
        expect(response.body).to include("1 School Lane, Building A, Quarter B, Leeds, West Yorkshire, LS1 1AA")
        expect(response.body).to include("URN: 112992")
        expect(response.body).to include("This school is not attached to any courses.")
        expect(response.body).to include("Remove #{provider_school.decorate.location_name} from your account")
        expect(response.body).not_to include("School code")
        expect(response.body).not_to include("govuk-table")
      end

      it "lists attached courses in the courses table" do
        course = create(
          :course,
          :published_postgraduate,
          provider:,
          name: "Biology",
          course_code: "B123",
          start_date: Time.zone.local(2026, 9, 1),
        )
        create(:course_school, course:, provider_school:, gias_school:)
        create(
          :course,
          :published_postgraduate,
          provider:,
          name: "History",
          course_code: "H100",
        )

        get publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, provider_school.uuid)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Biology (B123)")
        expect(response.body).to include("Course information")
        expect(response.body).to include("Fee-paying")
        expect(response.body).to include("QTS with PGCE")
        expect(response.body).to include("Full time")
        expect(response.body).to include("September 2026")
        expect(response.parsed_body.at_css(".govuk-tag")).to be_present
        expect(response.body).to include(
          publish_provider_recruitment_cycle_course_path(provider.provider_code, recruitment_cycle.year, "B123"),
        )
        expect(response.body).not_to include("History (H100)")
        expect(response.body).not_to include("This school is not attached to any courses.")
      end

      it "does not list discarded courses attached to the school" do
        course = create(:course, provider:, name: "Biology", course_code: "B123")
        create(:course_school, course:, provider_school:, gias_school:)
        course.discard

        get publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, provider_school.uuid)

        expect(response.body).to include("This school is not attached to any courses.")
        expect(response.body).not_to include("Biology (B123)")
        expect(response.body).not_to include("govuk-table")
      end

      it "returns not found for a school in another recruitment cycle" do
        other_cycle_school = create(
          :provider_school,
          provider: create(:provider, recruitment_cycle: find_or_create(:recruitment_cycle, year: remodel_cycle_year)),
        )

        get publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, other_cycle_school.uuid)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the same GIAS school is linked twice" do
      let(:recruitment_cycle) { find_or_create(:recruitment_cycle, year: remodel_cycle_year + 1) }
      let(:provider) { create(:provider, recruitment_cycle:) }
      let!(:normal_provider_school) { create(:provider_school, provider:, gias_school:, site_code: "A") }
      let!(:main_provider_school) { create(:provider_school, :main_site, provider:, gias_school:) }

      before { login_provider_user(provider) }

      it "displays the normal school without the main site suffix" do
        get publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, normal_provider_school.uuid)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("St Joseph")
        expect(response.body).to include("Catholic Primary School")
        expect(response.body).not_to include("(Main Site)")
      end

      it "displays the main site with the suffix" do
        get publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, main_provider_school.uuid)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("(Main Site)")
        expect(response.body).not_to include("School code")
      end
    end
  end

  describe "GET /publish/organisations/:provider_code/:recruitment_cycle_year/schools/:uuid/delete" do
    let(:recruitment_cycle) { find_or_create(:recruitment_cycle, year: remodel_cycle_year + 1) }
    let(:provider) { create(:provider, recruitment_cycle:) }
    let!(:provider_school) { create(:provider_school, provider:, gias_school:) }
    let!(:other_provider_school) { create(:provider_school, provider:) }

    before { login_provider_user(provider) }

    it "displays the delete page for the provider school" do
      get delete_publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, provider_school.uuid)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Remove #{provider_school.decorate.location_name}")
      expect(response.body).to include("Are you sure you want to remove this school from your account")
      expect(response.body).to include("This school is not attached to any courses")
      expect(response.body).to include(provider_school.full_address)
      expect(response.body).to include("URN: #{provider_school.urn}")
      expect(response.body).to include("Remove school from account")
    end

    it "links back to the school page by default" do
      get delete_publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, provider_school.uuid)

      expect(response.body).to include(
        publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, provider_school.uuid),
      )
    end

    it "links back to the filtered schools list when opened from the index" do
      get delete_publish_provider_recruitment_cycle_school_path(
        provider.provider_code,
        recruitment_cycle.year,
        provider_school.uuid,
        from: "index",
        filter: "Bramblewood",
      )

      expect(response.body).to include(
        publish_provider_recruitment_cycle_schools_path(
          provider.provider_code,
          recruitment_cycle.year,
          filter: "Bramblewood",
        ),
      )
    end

    context "when it is the provider's only school" do
      let!(:other_provider_school) { nil }

      it "explains that the provider would be left without a school" do
        get delete_publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, provider_school.uuid)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("You cannot remove #{provider_school.decorate.location_name} from your account")
        expect(response.body).to include("is the only school for #{provider.provider_name}")
        expect(response.body).to include("To remove it, you must first add another school.")
        expect(response.body).not_to include("govuk-button--warning")
      end
    end

    it "explains when the school is the only placement school on a course" do
      course = create(:course, provider:, name: "Primary", course_code: "X123")
      create(:course_school, course:, provider_school:, gias_school:)

      get delete_publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, provider_school.uuid)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("You cannot remove #{provider_school.decorate.location_name} from your account")
      expect(response.body).to include("only placement school attached to the following courses")
      expect(response.body).to include("Primary (X123)")
      expect(response.body).to include(
        publish_provider_recruitment_cycle_course_path(
          provider.provider_code,
          recruitment_cycle.year,
          course.course_code,
        ),
      )
      expect(response.body).not_to include("govuk-button--warning")
    end

    it "lists courses that will be detached when the school is not the only school on them" do
      course = create(:course, provider:, name: "Primary", course_code: "X123")
      create(:course_school, course:, provider_school:, gias_school:)
      create(:course_school, course:, provider_school: other_provider_school, gias_school: other_provider_school.gias_school)

      get delete_publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, provider_school.uuid)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Remove #{provider_school.decorate.location_name}")
      expect(response.body).to include("detach it from 1 course")
      expect(response.body).to include("govuk-warning-text")
      expect(response.body).to include("Primary (X123)")
      expect(response.body).to include("Remove school from account and detach from 1 course")
    end

    it "only lists courses where this school is the only placement school" do
      sole_course = create(:course, provider:, name: "Sole Course", course_code: "S1")
      shared_course = create(:course, provider:, name: "Shared Course", course_code: "S2")
      create(:course_school, course: sole_course, provider_school:, gias_school:)
      create(:course_school, course: shared_course, provider_school:, gias_school:)
      create(:course_school, course: shared_course, provider_school: other_provider_school, gias_school: other_provider_school.gias_school)

      get delete_publish_provider_recruitment_cycle_school_path(provider.provider_code, recruitment_cycle.year, provider_school.uuid)

      expect(response.body).to include("You cannot remove #{provider_school.decorate.location_name} from your account")
      expect(response.body).to include("Sole Course (S1)")
      expect(response.body).not_to include("Shared Course (S2)")
    end
  end

  describe "DELETE /publish/organisations/:provider_code/:recruitment_cycle_year/schools/:uuid" do
    let(:provider) { create(:provider) }
    let!(:site) { create(:site, provider:, urn: gias_school.urn, code: "A", uuid: SecureRandom.uuid) }
    let!(:provider_school) do
      create(:provider_school, provider:, gias_school:, site_code: site.code, uuid: site.uuid)
    end
    let!(:other_provider_school) { create(:provider_school, provider:) }
    let!(:exempt_course) { create(:course, :with_salary, provider:, publish_without_schools_allowed: true) }

    before { login_provider_user(provider) }

    def remove_school
      delete publish_provider_recruitment_cycle_school_path(provider.provider_code, provider.recruitment_cycle.year, provider_school.uuid)
    end

    it "removes the school" do
      expect { remove_school }.to change { provider.schools.count }.by(-1)

      expect(response).to redirect_to(publish_provider_recruitment_cycle_schools_path(provider.provider_code, provider.recruitment_cycle.year))
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
      expect(flash[:warning]).to eq("This school could not be removed because it is the only placement school attached to a course")
    end

    it "removes a school that is not the only school on its courses" do
      course = create(:course, provider:)
      create(:course_school, course:, gias_school:, provider_school:)
      create(:course_school, course:, gias_school: other_provider_school.gias_school, provider_school: other_provider_school)

      expect { remove_school }.to change { provider.schools.count }.by(-1)

      expect(course.schools.reload.map(&:provider_school)).to contain_exactly(other_provider_school)
      expect(flash[:success]).to eq("#{provider_school.decorate.location_name} has been removed from your account")
    end

    it "does not remove the provider's last school" do
      other_provider_school.destroy!

      expect { remove_school }.not_to(change { provider.schools.count })

      expect(response).to redirect_to(delete_publish_provider_recruitment_cycle_school_path(provider.provider_code, provider.recruitment_cycle.year, provider_school.uuid))
      expect(flash[:warning]).to eq("This school could not be removed because it is your only school")
    end

    it "keeps the original return params when the school cannot be removed" do
      course = create(:course, provider:)
      create(:course_school, course:, gias_school:, provider_school:)

      delete publish_provider_recruitment_cycle_school_path(
        provider.provider_code,
        provider.recruitment_cycle.year,
        provider_school.uuid,
        from: "index",
        filter: "Bramblewood",
      )

      expect(response).to redirect_to(
        delete_publish_provider_recruitment_cycle_school_path(
          provider.provider_code,
          provider.recruitment_cycle.year,
          provider_school.uuid,
          from: "index",
          filter: "Bramblewood",
        ),
      )
    end
  end
end
