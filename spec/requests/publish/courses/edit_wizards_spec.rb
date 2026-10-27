# frozen_string_literal: true

require "rails_helper"

describe "Publish::Courses::EditWizardsController", service: :publish do
  include DfESignInUserHelper

  around do |example|
    previous = Settings.features.course_edit_wizard
    Settings.features.course_edit_wizard = true
    example.run
  ensure
    Settings.features.course_edit_wizard = previous
  end

  let(:user) { create(:user, :with_provider) }
  let(:provider) { user.providers.first }
  let(:course) { create(:course, :fee, provider:, can_sponsor_student_visa: false, accrediting_provider: provider) }
  let(:course_path) { "/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/courses/#{course.course_code}" }

  before { login_user(user) }

  # An edit is a funding type edit or a visa edit, and the funding type
  # policy depends on which. One whose stored unit is missing has ended.
  it "ends an edit with no stored unit" do
    get "#{course_path}/edit/funding_type"
    step_path = URI.parse(response.location).path
    remove_the_stored_unit(step_path.split("/")[-2])

    get step_path

    expect(response).to redirect_to("#{course_path}/details")
    expect(flash[:info]).to eq("This change has already been saved or has expired. Check the course details.")
  end

  it "refuses a funding type edit of a course that cannot change its funding type" do
    create(:course_enrichment, :published, course:)

    get "#{course_path}/edit/funding_type"

    expect(response).to have_http_status(:forbidden)
  end

  # A Change link names the step it opens on. The funding type policy
  # follows the unit that holds that step.
  it "opens a visa edit on the named step when the course cannot change its funding type" do
    course.update!(can_sponsor_student_visa: true)
    create(:course_enrichment, :published, course:)

    get "#{course_path}/edit/visa_sponsorship_application_deadline_required"

    expect(URI.parse(response.location).path).to end_with("/visa_sponsorship_application_deadline_required")
  end

private

  def remove_the_stored_unit(state_key)
    repository = CourseWizard::Repositories::CourseEdit.new(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, state_key:, expires_in: 1.hour,
    )
    repository.write(edit: repository.read.fetch(:edit).except(:unit))
    expect(repository.read[:edit]).not_to have_key(:unit)
  end
end
