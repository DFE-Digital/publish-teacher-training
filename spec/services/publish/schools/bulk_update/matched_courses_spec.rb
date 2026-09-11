# frozen_string_literal: true

require "rails_helper"

describe Publish::Schools::BulkUpdate::MatchedCourses do
  let(:provider) { create(:provider) }

  def school(name)
    @schools ||= {}
    @schools[name] ||= begin
      create(:site, :with_provider_school, provider:, location_name: name)
      provider.reload.schools.joins(:gias_school).find_by!(gias_school: { name: name })
    end
  end

  def course_with(*names, **overrides)
    create(:course, :primary, provider:, sites: [], **overrides).tap do |course|
      names.each do |name|
        create(:course_school, course:, provider_school: school(name), gias_school: school(name).gias_school)
      end
    end
  end

  def matched(course, added: [], removed: [], token: "all")
    described_class.new(
      scope: Publish::Schools::BulkUpdate::Scope.find(course: course.reload, token:),
      added_uuids: added.map { |name| school(name).uuid },
      removed_uuids: removed.map { |name| school(name).uuid },
    )
  end

  describe "the courses that will be updated" do
    it "is every course the scope matched" do
      course = course_with("Ash")
      other = course_with("Beech")

      expect(matched(course).updatable.map(&:id)).to contain_exactly(course.id, other.id)
      expect(matched(course).count).to eq(2)
    end

    it "carries the status the course list shows, without loading enrichments" do
      course = course_with("Ash")

      expect(matched(course).updatable.first.read_attribute(:content_status)).to eq("draft")
    end

    # The table reads what the decorator adds - a primary course's age range -
    # so the rows go out the way the course list sends its own: decorated.
    it "is decorated, as the course list's rows are" do
      course = course_with("Ash")

      expect(matched(course).updatable.first).to respond_to(:age_range)
      expect(matched(course, removed: %w[Ash]).excluded).to all(respond_to(:age_range))
    end

    it "is only this course when that is the scope" do
      course = course_with("Ash")
      course_with("Beech")

      expect(matched(course, token: "only_this_course").updatable.map(&:id)).to contain_exactly(course.id)
    end
  end

  describe "the courses that will not be updated" do
    it "leaves out a course whose only schools are being removed" do
      course = course_with("Ash", "Beech")
      last_school = course_with("Ash")

      result = matched(course, removed: %w[Ash])

      expect(result.updatable.map(&:id)).to contain_exactly(course.id)
      expect(result.excluded.map(&:id)).to contain_exactly(last_school.id)
      expect(result.count).to eq(1)
    end

    it "keeps a course support has allowed to publish without schools" do
      course = course_with("Ash", "Beech")
      exempt = course_with("Ash", publish_without_schools_allowed: true)

      result = matched(course, removed: %w[Ash])

      expect(result.updatable.map(&:id)).to contain_exactly(course.id, exempt.id)
      expect(result.excluded).to be_empty
    end

    # It has no school to lose, so the explanation - that the schools being
    # removed are its only ones - would not be true of it.
    it "keeps a course that already has no schools" do
      course = course_with("Ash", "Beech")
      empty = course_with

      result = matched(course, removed: %w[Ash])

      expect(result.updatable.map(&:id)).to include(empty.id)
      expect(result.excluded).to be_empty
    end

    it "excludes nothing when schools are being added" do
      course = course_with("Ash", "Beech")
      course_with("Ash")

      result = matched(course, added: %w[Cedar], removed: %w[Ash])

      expect(result.excluded).to be_empty
      expect(result.count).to eq(2)
    end
  end

  describe "query count" do
    def materialise(course_count)
      course = course_with("Ash", "Beech")
      course_count.times { course_with("Ash") }
      result = matched(course.reload, removed: %w[Ash])

      count_queries { [result.updatable, result.excluded, result.count] }
    end

    it "does not grow with the number of courses matched" do
      expect(materialise(10)).to eq(materialise(2))
    end

    # A count of queries cannot catch this: the number was always constant, it
    # was the rows read inside them that grew. Unbounded, Postgres materialises
    # every course_school row in the table and rescans it once per matched
    # course - seconds, for a provider with a few hundred courses.
    it "reads no more of course_school than the courses it matched" do
      course = course_with("Ash", "Beech")
      course_with("Ash")
      result = matched(course.reload, removed: %w[Ash])

      exclusion = queries { result.excluded }.grep(/NOT IN/).first

      expect(exclusion).to be_present
      exclusion.scan(/FROM "course_school"/).size.times do
        expect(exclusion).to include(%(WHERE "course_school"."course_id" IN))
      end
      expect(exclusion.scan(/FROM "course_school"/).size)
        .to eq(exclusion.scan(/"course_school"."course_id" IN/).size)
    end
  end

  describe "the ids handed to the write" do
    # The confirm action renders nothing, so it must not pay for the list. This
    # holds only because the list query LEFT joins everything it joins - an
    # inner join would drop a matched course here and it would never be written.
    it "are the courses that will be updated, without building the list" do
      course = course_with("Ash", "Beech")
      last_school = course_with("Ash")
      result = matched(course.reload, removed: %w[Ash])

      expect(result.ids).to contain_exactly(course.id)
      expect(result.ids).not_to include(last_school.id)
      expect(result.count).to eq(result.ids.size)
    end

    it "cost less than rendering the list" do
      course = course_with("Ash", "Beech")
      course_with("Ash")

      for_write = count_queries { matched(course.reload, removed: %w[Ash]).ids }
      for_the_page = count_queries { matched(course.reload, removed: %w[Ash]).updatable }

      expect(for_write).to be < for_the_page
    end

    it "agree with the courses the page lists" do
      course = course_with("Ash", "Beech")
      course_with("Beech")
      result = matched(course.reload, added: %w[Cedar])

      expect(result.ids).to match_array(result.updatable.map(&:id))
    end
  end
end
