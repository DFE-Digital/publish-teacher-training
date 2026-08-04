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

  def pair_site
    site = create(:site, :with_provider_school, provider:)
    [site, provider.schools.find_by(uuid: site.uuid)]
  end

  def build_course(submitted:, sites:, provider_schools:)
    build(:course, provider:, sites:).tap do |course|
      course.submitted_school_uuids = submitted
      provider_schools.each do |provider_school|
        course.schools.build(gias_school: provider_school.gias_school, provider_school:)
      end
    end
  end

  context "when the submission, the sites and the schools all agree" do
    let(:course) do
      site, provider_school = pair_site
      build_course(submitted: [site.uuid], sites: [site], provider_schools: [provider_school])
    end

    it { is_expected.to be_empty }
  end

  context "when a submitted UUID resolved to nothing" do
    let(:course) { build_course(submitted: [SecureRandom.uuid], sites: [], provider_schools: []) }

    it "reports it rather than letting it look like an empty selection" do
      expect(errors).to include(unresolved_message)
    end
  end

  context "when only some of the submitted UUIDs resolved" do
    let(:course) do
      site, provider_school = pair_site
      build_course(submitted: [site.uuid, SecureRandom.uuid], sites: [site], provider_schools: [provider_school])
    end

    it { is_expected.to include(unresolved_message) }
  end

  context "when a site has no matching Course::School" do
    let(:course) do
      site = create(:site, provider:)
      build_course(submitted: [site.uuid], sites: [site], provider_schools: [])
    end

    it { is_expected.to include(unresolved_message) }
  end

  context "when a Course::School has no matching site" do
    let(:course) do
      _site, provider_school = pair_site
      other = create(:site, provider:)
      build_course(submitted: [other.uuid], sites: [other], provider_schools: [provider_school])
    end

    it { is_expected.to include(unresolved_message) }
  end

  # A checkbox group posts a hidden blank value when nothing is ticked, so an
  # empty submission arrives as [""] rather than [].
  context "when nothing was selected" do
    let(:course) { build_course(submitted: [""], sites: [], provider_schools: []) }

    it "leaves it to CoursePublishableSchoolsPresenceValidator" do
      expect(errors).to be_empty
      expect(course.errors.full_messages_for(:sites)).to include("Select at least one school")
    end
  end

  # The legacy sites_ids path never sets the accessor, so there is no submission
  # to hold the sites to - only the dual write itself gets checked.
  context "when the course was not built from submitted UUIDs" do
    let(:course) do
      site, provider_school = pair_site
      build_course(submitted: nil, sites: [site], provider_schools: [provider_school])
    end

    it { is_expected.to be_empty }

    it "still catches a site with no Course::School" do
      site = create(:site, provider:)
      course = build_course(submitted: nil, sites: [site], provider_schools: [])

      course.valid?(:new)

      expect(course.errors.full_messages_for(:schools)).to include(unresolved_message)
    end
  end

  it "does not run outside the :new context" do
    site = create(:site, provider:)
    course = build_course(submitted: [site.uuid], sites: [site], provider_schools: [])

    course.valid?(:publish)

    expect(course.errors.full_messages_for(:schools)).to be_empty
  end
end
