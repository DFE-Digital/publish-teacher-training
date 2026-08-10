# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support::CopyCourses" do
  include DfESignInUserHelper
  let(:user) { create(:user, :admin) }
  let(:source_provider) { create(:provider, courses: create_list(:course, 3, :with_full_time_sites)) }
  let!(:target_provider) { create(:provider) }
  let!(:year) { find_or_create(:recruitment_cycle).year }

  def link_school(provider, gias_school, site_code)
    site = create(:site, provider:, urn: gias_school.urn, code: site_code)
    create(:provider_school, provider:, gias_school:, site_code:, uuid: site.uuid)
  end

  before { host! URI(Settings.base_url).host }

  describe "GET new" do
    it "responds with 200" do
      login_user(user)
      get "/support/#{RecruitmentCycle.current.year}/providers/#{source_provider.id}/copy_courses/new"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST create" do
    it "copies the courses and shows flash message" do
      login_user(user)
      post "/support/#{year}/providers/#{target_provider.id}/copy_courses", params: { "course[autocompleted_provider_code]" => source_provider.provider_code }
      expect(target_provider.reload.courses.length).to eq(3)

      expect(response).to redirect_to(support_recruitment_cycle_provider_courses_path(year, target_provider.id))
      follow_redirect!
      expect(response.parsed_body.css(".govuk-notification-banner--success").text).to match(sprintf("Courses copied: %s", source_provider.courses.map(&:course_code).sort.to_sentence))
    end

    context "with schools" do
      let(:source_course) { source_provider.courses.first }
      let(:shared_gias_school) { create(:gias_school, :open) }
      let(:unlinked_gias_school) { create(:gias_school, :open) }
      # The target provider keeps its own site code for the shared school.
      let!(:target_school) { link_school(target_provider, shared_gias_school, "Z") }

      before do
        [shared_gias_school, unlinked_gias_school].each_with_index do |gias_school, index|
          provider_school = link_school(source_provider, gias_school, ("A".."Z").to_a[index])
          create(:course_school, course: source_course, provider_school:, gias_school:)
        end
      end

      it "copies the placement schools the target provider already has" do
        login_user(user)
        post "/support/#{year}/providers/#{target_provider.id}/copy_courses", params: { "course[autocompleted_provider_code]" => source_provider.provider_code, "support_copy_courses_form" => { "schools" => "true" } }

        expect(target_provider.reload.courses.length).to eq(3)

        copied_course = target_provider.courses.find_by!(course_code: source_course.course_code)
        expect(copied_course.schools.pluck(:provider_school_id)).to eq([target_school.id])
        expect(copied_course.sites.pluck(:uuid)).to eq([target_school.uuid])

        expect(response).to redirect_to(support_recruitment_cycle_provider_courses_path(year, target_provider.id))
        follow_redirect!
        expect(response.parsed_body.css(".govuk-notification-banner--success").text).to match(sprintf("Courses copied: %s", source_provider.courses.map(&:course_code).sort.to_sentence))
      end

      it "does not copy placement schools the target provider does not have" do
        login_user(user)
        post "/support/#{year}/providers/#{target_provider.id}/copy_courses", params: { "course[autocompleted_provider_code]" => source_provider.provider_code, "support_copy_courses_form" => { "schools" => "true" } }

        expect(target_provider.reload.schools.pluck(:gias_school_id)).to eq([shared_gias_school.id])
        expect(target_provider.sites.pluck(:uuid)).to eq([target_school.uuid])
      end

      it "copies no placement schools when the box is left unticked" do
        login_user(user)
        post "/support/#{year}/providers/#{target_provider.id}/copy_courses", params: { "course[autocompleted_provider_code]" => source_provider.provider_code }

        copied_course = target_provider.reload.courses.find_by!(course_code: source_course.course_code)
        expect(copied_course.schools).to be_empty
        expect(copied_course.sites).to be_empty
      end
    end

    context "course code already exists on target provider" do
      let(:source_provider) { create(:provider, courses: [create(:course)]) }
      let!(:target_provider) { create(:provider, courses: [create(:course, course_code: source_provider.courses.first.course_code)]) }

      it "notifies user that the course was not copied" do
        login_user(user)
        post "/support/#{year}/providers/#{target_provider.id}/copy_courses", params: { "course[autocompleted_provider_code]" => source_provider.provider_code }

        expect(response).to redirect_to(support_recruitment_cycle_provider_courses_path(year, target_provider.id))
        follow_redirect!

        # Warning messages use the base notification banner (not --success)
        notification_banners = response.parsed_body.css(".govuk-notification-banner:not(.govuk-notification-banner--success)")
        expect(notification_banners.text).to match(sprintf("Courses not copied: %s", source_provider.courses.map(&:course_code).to_sentence))
      end
    end

    context "when copying courses to the same provider" do
      it "renders the new action with error messages" do
        login_user(user)

        post "/support/#{year}/providers/#{target_provider.id}/copy_courses", params: { "course[autocompleted_provider_code]" => target_provider.provider_code }

        expect(response.parsed_body.css(".govuk-error-summary").text).to match("Choose different providers")
      end
    end
  end
end
