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

  # The course code is part of the edit's key, so one course's edit URL
  # cannot open another course's answers
  it "ends an edit opened from another course's URL" do
    get "#{course_path}/edit/funding_type"
    other_course = create(:course, :fee, provider:)

    get response.location.sub("/courses/#{course.course_code}/", "/courses/#{other_course.course_code}/")

    expect(response).to redirect_to("#{course_path.sub(course.course_code, other_course.course_code)}/details")
    expect(flash[:info]).to eq("This change has already been saved or has expired. Check the course details.")
  end

  # The unit is part of the edit's key: a funding type answer cannot be saved
  # through a visa URL, which skips the funding type check
  it "ends an edit whose URL is changed to another unit, saving nothing" do
    get "#{course_path}/edit/funding_type"
    funding_type_url = response.location
    patch funding_type_url, params: { funding_type: { funding_type: "salary" } }
    create(:course_enrichment, :published, course:)

    patch funding_type_url.sub("/edit/funding_type/", "/edit/visa/").sub("/funding_type?", "/skilled_worker_visa?"),
          params: { skilled_worker_visa: { can_sponsor_skilled_worker_visa: "true" } }

    expect(response).to redirect_to("#{course_path}/details")
    expect(flash[:info]).to eq("This change has already been saved or has expired. Check the course details.")
    expect(course.reload.funding).to eq("fee")
  end

  # An ended edit says so, even when the course can no longer change its
  # funding type
  it "ends an expired funding type edit of a course published since" do
    get "#{course_path}/edit/funding_type"
    funding_type_url = response.location
    Rails.cache.clear
    create(:course_enrichment, :published, course:)

    get funding_type_url

    expect(response).to redirect_to("#{course_path}/details")
    expect(flash[:info]).to eq("This change has already been saved or has expired. Check the course details.")
  end

  # A request that finishes after the edit was saved can write one of its
  # answers back. The edit stays ended.
  it "ends an edit that a late request wrote an answer back to" do
    get "#{course_path}/edit/funding_type"
    funding_type_url = response.location
    repository = edit_repository(state_key: URI.parse(funding_type_url).path.split("/")[-2])
    repository.clear
    repository.write(funding_type: "salary")

    get funding_type_url

    expect(response).to redirect_to("#{course_path}/details")
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

  def edit_repository(state_key:)
    CourseWizard::Repositories::CourseEdit.new(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year,
      course_code: course.course_code, unit: :funding_type, state_key:, expires_in: 1.hour
    )
  end
end
