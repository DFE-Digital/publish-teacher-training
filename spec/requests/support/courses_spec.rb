# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support::Courses publish_without_schools_allowed", travel: mid_cycle do
  include DfESignInUserHelper

  let(:provider) { create(:provider) }
  let(:year) { provider.recruitment_cycle_year }

  before { host! URI(Settings.base_url).host }

  def update_course(course)
    patch "/support/#{year}/providers/#{provider.id}/courses/#{course.id}",
          params: { support_edit_course_form: { publish_without_schools_allowed: "true" } }
  end

  context "as a support (admin) user" do
    let(:admin) { create(:user, :admin) }

    it "allows a salaried course to be published without schools" do
      course = create(:course, :with_salary, provider:)
      login_user(admin)

      update_course(course)

      expect(course.reload.publish_without_schools_allowed).to be(true)
    end

    it "allows an apprenticeship course to be published without schools" do
      course = create(:course, :apprenticeship, provider:)
      login_user(admin)

      update_course(course)

      expect(course.reload.publish_without_schools_allowed).to be(true)
    end

    it "ignores the flag for a fee course" do
      course = create(:course, funding: "fee", provider:)
      login_user(admin)

      update_course(course)

      expect(course.reload.publish_without_schools_allowed).to be(false)
    end
  end

  context "as a provider (non-admin) user" do
    let(:user) { create(:user, providers: [provider]) }

    it "cannot update the flag through forged params" do
      course = create(:course, :with_salary, provider:)
      login_user(user)

      update_course(course)

      expect(response).to have_http_status(:forbidden)
      expect(course.reload.publish_without_schools_allowed).to be(false)
    end
  end
end
