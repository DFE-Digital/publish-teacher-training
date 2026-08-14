# frozen_string_literal: true

require "rails_helper"

# Reproduces the divergence found in the 2027 cycle after rollover.
#
# A course's placement schools are stored twice:
#
#   old model: course_site   -> SiteStatus -> Site
#   new model: course_school -> Course::School -> Provider::School -> GiasSchool
#
# Rollover writes both, through Rollover::Schools::DualCourseCopier. After it
# runs, the two must describe the SAME set of schools. Every example below is a
# real 2027 defect reduced to the smallest setup that shows it.
#
# The root cause of most of them is that the two copiers identify a school
# differently:
#
#   LegacyCourseCopier  -> new_provider.sites.index_by(&:code)          # code alone
#   CourseCopier        -> [gias_school_id, site_code]                  # the unique key
#
# `site.code` has no unique index, so a provider can hold the same code on many
# different schools. `index_by` keeps only the last one.
RSpec.describe "Rollover school copy divergence" do
  let(:provider)     { create(:provider, provider_code: "ABC") }
  let(:new_provider) do
    create(:provider, provider_code: "ABC", recruitment_cycle: create(:recruitment_cycle, :next))
  end
  let(:course)     { create(:course, provider:, course_code: "X123") }
  let(:new_course) { create(:course, provider: new_provider, course_code: "X123") }

  # Attaches a school to the source provider in both models, the way a real
  # provider's data looks: a legacy Site plus its paired Provider::School.
  def add_school_to_provider(code:, urn:, name:)
    site = create(:site, :with_gias_school, provider:, code:, urn:, location_name: name)
    create(:provider_school, :for_site, site:)
    site
  end

  # Places the course at that school in both models.
  def place_course_at(site, status: :running)
    create(:site_status, course:, site:, status:)
    create(:course_school, :for_site, course:, site:)
  end

  # What rollover actually does: copy the provider's schools first, then the
  # course's placements.
  def roll_over!
    Rollover::Schools::DualProviderCopier.new(
      legacy_copier: Rollover::Schools::LegacyProviderCopier.new(site_copier: Sites::CopyToProviderService.new),
      new_copier: Rollover::Schools::ProviderCopier.new,
    ).execute(provider:, new_provider:)

    Rollover::Schools::DualCourseCopier.new(
      legacy_copier: Rollover::Schools::LegacyCourseCopier.new(site_copier: Sites::CopyToCourseService),
      new_copier: Rollover::Schools::CourseCopier.new,
    ).call(course:, new_provider:, new_course:)
  end

  # The schools the OLD model says the rolled-over course is placed at.
  def schools_per_course_site
    new_course.site_statuses.map { |site_status| site_status.site.location_name }.sort
  end

  # The schools the NEW model says the rolled-over course is placed at.
  def schools_per_course_school
    new_course.schools.map { |course_school| course_school.provider_school.gias_school.name }.sort
  end

  describe "1 + 2. two schools share a site code" do
    # The provider holds code "AAA" on two different schools. This is normal in
    # production: 6B1 has 3,014 school sites and only 652 distinct codes.
    before do
      place_course_at add_school_to_provider(code: "AAA", urn: "100001", name: "Alpha School")
      place_course_at add_school_to_provider(code: "AAA", urn: "100002", name: "Beta School")

      roll_over!
    end

    it "keeps both schools in the new model" do
      expect(schools_per_course_school).to eq(["Alpha School", "Beta School"])
    end

    # ISSUE 2 - LOST PLACEMENT. Both source sites resolve to the single entry
    # `index_by(&:code)` kept for "AAA", so one school loses its placement.
    it "keeps both schools in the old model" do
      expect(schools_per_course_site).to eq(["Alpha School", "Beta School"])
    end

    # ISSUE 1 - WRONG SCHOOL / ISSUE 2 - LOST PLACEMENT, stated as the invariant
    # rollover has to hold.
    it "leaves the two models agreeing" do
      expect(schools_per_course_site).to eq(schools_per_course_school)
    end
  end

  describe "5. duplicate course_site rows (regression guard - already fixed)" do
    # Same collision as above. Every source site sharing the code resolves to the
    # same destination site. Before 054f3973c ("Stop rollover duplicating provider
    # sites", 2026-08-10) each one wrote its own row, so course 6B1/T998 ended up
    # with 2,306 course_site rows pointing at a single site.
    #
    # `Sites::CopyToCourseService` now uses find_or_create_by, so this PASSES.
    # The duplicate rows still sitting in 2027 are residue from a rollover run
    # made before that commit and need cleaning up separately.
    before do
      place_course_at add_school_to_provider(code: "AAA", urn: "100001", name: "Alpha School")
      place_course_at add_school_to_provider(code: "AAA", urn: "100002", name: "Beta School")

      roll_over!
    end

    it "writes at most one course_site row per site" do
      site_ids = new_course.site_statuses.map(&:site_id)

      expect(site_ids).to eq(site_ids.uniq)
    end
  end

  describe "3. a discarded, URN-less site still attached to the course" do
    # The discard script removed the site but left its course_site row behind.
    # It has no course_school (the backfill skipped it), but the old model still
    # copies it - `Course#sites` is not `.kept`-scoped, and
    # `Site.with_available_gias_school` deliberately exempts `urn: nil`.
    #
    # Its code then resolves to a completely unrelated live school.
    before do
      # A live school the course is NOT placed at, holding code "W".
      add_school_to_provider(code: "W", urn: "100003", name: "Unrelated School")

      # The dead row: same code, no URN, discarded. Built without validation
      # because Site now requires a URN - these rows predate that rule.
      dead_site = build(:site, provider:, code: "W", urn: nil,
                               location_name: "Old Campus", discarded_at: Time.zone.now)
      dead_site.save!(validate: false)
      create(:site_status, course:, site: dead_site, status: :running)

      roll_over!
    end

    it "does not invent a placement at a school the course never had" do
      expect(schools_per_course_site).to be_empty
    end

    it "leaves the two models agreeing" do
      expect(schools_per_course_site).to eq(schools_per_course_school)
    end
  end

  describe "4. a suspended placement" do
    # The schools backfill has no status filter (executor.rb:65-89), so it made a
    # course_school for this placement. `Course#sites` only yields
    # status IN ('N','R') (course.rb:172), so the legacy copier cannot see it.
    #
    # The new model carries it to 2027, the old one does not. Either side could
    # be the correct fix - what is not acceptable is the two disagreeing.
    before do
      place_course_at add_school_to_provider(code: "S", urn: "100004", name: "Suspended School"),
                      status: :suspended

      roll_over!
    end

    it "leaves the two models agreeing" do
      expect(schools_per_course_site).to eq(schools_per_course_school)
    end
  end
end
