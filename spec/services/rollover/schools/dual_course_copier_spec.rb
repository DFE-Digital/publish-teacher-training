# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rollover::Schools::DualCourseCopier do
  subject(:copy_schools) do
    described_class.new(
      legacy_copier: Rollover::Schools::LegacyCourseCopier.new(site_copier: Sites::CopyToCourseService),
      new_copier: Rollover::Schools::CourseCopier.new,
    ).call(course:, new_provider:, new_course:)
  end

  let(:provider) { create(:provider) }
  let(:new_provider) { create(:provider, recruitment_cycle: create(:recruitment_cycle, :next)) }
  let!(:legacy_site) { create(:site, :with_gias_school, provider:, code: "S") }
  let!(:provider_school) { create(:provider_school, provider:, site_code: "B") }
  let(:course) { create(:course, provider:) }
  let!(:site_status) { create(:site_status, course:, site: legacy_site, status: :running) }
  let!(:course_school) do
    create(
      :course_school,
      course:,
      provider_school:,
      gias_school: provider_school.gias_school,
      site_code: provider_school.site_code,
    )
  end

  let!(:new_legacy_site) { create(:site, provider: new_provider, code: legacy_site.code) }
  let!(:new_provider_school) do
    create(
      :provider_school,
      provider: new_provider,
      gias_school: provider_school.gias_school,
      site_code: provider_school.site_code,
    )
  end
  let(:new_course) { create(:course, provider: new_provider, course_code: course.course_code) }

  it "copies both legacy SiteStatus and new Course::School records" do
    expect { copy_schools }
      .to change(new_course.site_statuses, :count).by(1)
      .and change(new_course.schools, :count).by(1)
  end

  it "links the copied SiteStatus to the copied Site" do
    copy_schools

    expect(new_course.site_statuses.first.site).to eq(new_legacy_site)
  end

  it "links the copied Course::School to the copied Provider::School" do
    copy_schools

    copied_course_school = new_course.schools.find_by!(gias_school_id: course_school.gias_school_id)

    expect(copied_course_school.provider_school).to eq(new_provider_school)
    expect(copied_course_school).to have_attributes(
      provider_school_id: new_provider_school.id,
      gias_school_id: course_school.gias_school_id,
    )
  end

  it "copies neither the SiteStatus nor the Course::School when the GIAS record has closed" do
    closed_gias_school = create(:gias_school, :closed)

    closed_site = create(:site, provider:, code: "Z", urn: closed_gias_school.urn)
    create(:site_status, course:, site: closed_site, status: :running)
    # A matching new site exists, so exclusion must come from the availability
    # filter rather than merely a missing destination site.
    create(:site, provider: new_provider, code: "Z", urn: closed_gias_school.urn)

    closed_provider_school = create(:provider_school, provider:, gias_school: closed_gias_school, site_code: "Y")
    create(:course_school, course:, provider_school: closed_provider_school, gias_school: closed_gias_school, site_code: "Y")

    copy_schools

    expect(new_course.site_statuses.map { |site_status| site_status.site.code }).not_to include("Z")
    expect(new_course.schools.pluck(:gias_school_id)).not_to include(closed_gias_school.id)
  end
end
