# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseSchoolSelectionValidator do
  # full_messages_for, not errors[:schools]: the message carries a `^` marker
  # that custom_error_message strips along with the attribute-name prefix, so
  # this is the sentence the provider actually reads.
  subject(:errors) do
    course.valid?(:new)
    course.errors.full_messages_for(:schools)
  end

  let(:provider) { create(:provider, sites: [], schools: []) }
  let(:unresolved_message) do
    "Some of the schools you selected were not recognised. " \
      "Try again or get in touch with support at #{Settings.support_email}"
  end

  def build_course(submitted:, provider_schools:)
    build(:course, provider:, sites: []).tap do |course|
      course.submitted_school_uuids = submitted
      provider_schools.each do |provider_school|
        course.schools.build(gias_school: provider_school.gias_school, provider_school:)
      end
    end
  end

  context "when every submitted UUID became a Course::School" do
    let(:course) do
      provider_school = create(:provider_school, provider:)
      build_course(submitted: [provider_school.uuid], provider_schools: [provider_school])
    end

    it { is_expected.to be_empty }

    it "does not write a legacy site status" do
      expect(course.site_statuses).to be_empty
    end
  end

  context "when a submitted UUID resolved to nothing" do
    let(:course) { build_course(submitted: [SecureRandom.uuid], provider_schools: []) }

    it "reports it rather than letting it look like an empty selection" do
      expect(errors).to include(unresolved_message)
    end
  end

  context "when only some of the submitted UUIDs resolved" do
    let(:course) do
      provider_school = create(:provider_school, provider:)
      build_course(submitted: [provider_school.uuid, SecureRandom.uuid], provider_schools: [provider_school])
    end

    it { is_expected.to include(unresolved_message) }
  end

  # A checkbox group posts a hidden blank value when nothing is ticked, so an
  # empty submission arrives as [""] rather than [].
  context "when nothing was selected" do
    let(:course) { build_course(submitted: [""], provider_schools: []) }

    it "leaves it to CoursePublishableSchoolsPresenceValidator" do
      expect(errors).to be_empty
      expect(course.errors.full_messages_for(:sites)).to include("Select at least one school")
    end
  end

  context "when the course was not built from submitted UUIDs" do
    let(:course) do
      provider_school = create(:provider_school, provider:)
      build_course(submitted: nil, provider_schools: [provider_school])
    end

    it { is_expected.to be_empty }
  end

  it "does not run outside the :new context" do
    course = build_course(submitted: [SecureRandom.uuid], provider_schools: [])

    course.valid?(:publish)

    expect(course.errors.full_messages_for(:schools)).to be_empty
  end
end
