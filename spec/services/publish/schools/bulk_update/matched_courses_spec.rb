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
    def count_queries(&)
      count = 0
      counter = ->(_name, _start, _finish, _id, payload) { count += 1 unless payload[:name].to_s =~ /SCHEMA|TRANSACTION/ }
      ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &)
      count
    end

    def materialise(course_count)
      course = course_with("Ash", "Beech")
      course_count.times { course_with("Ash") }
      result = matched(course.reload, removed: %w[Ash])

      count_queries { [result.updatable, result.excluded, result.count] }
    end

    it "does not grow with the number of courses matched" do
      expect(materialise(10)).to eq(materialise(2))
    end
  end
end
