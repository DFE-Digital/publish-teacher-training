# frozen_string_literal: true

require "rails_helper"

describe Publish::Schools::BulkUpdate::Apply do
  let(:provider) { create(:provider) }

  def school(name)
    @schools ||= {}
    @schools[name] ||= begin
      create(:site, :with_provider_school, provider:, location_name: name)
      provider.reload.schools.joins(:gias_school).find_by!(gias_school: { name: name })
    end
  end

  def course_with(*names)
    create(:course, provider:, sites: []).tap do |course|
      names.each do |name|
        create(:course_school, course:, provider_school: school(name), gias_school: school(name).gias_school)
      end
    end
  end

  def attached_names(course)
    course.reload.schools.joins(:gias_school).pluck("gias_school.name")
  end

  def apply(courses:, added: [], removed: [])
    described_class.call(
      courses:,
      added_uuids: added.map { |name| school(name).uuid },
      removed_uuids: removed.map { |name| school(name).uuid },
    )
  end

  it "adds the schools to every course" do
    one = course_with("Ash")
    two = course_with("Beech")

    apply(courses: Course.where(id: [one.id, two.id]), added: %w[Cedar])

    expect(attached_names(one)).to contain_exactly("Ash", "Cedar")
    expect(attached_names(two)).to contain_exactly("Beech", "Cedar")
  end

  it "removes the schools from every course that has them" do
    one = course_with("Ash", "Beech")
    two = course_with("Beech")

    apply(courses: Course.where(id: [one.id, two.id]), removed: %w[Ash])

    expect(attached_names(one)).to contain_exactly("Beech")
    expect(attached_names(two)).to contain_exactly("Beech")
  end

  it "leaves a school a course already has attached exactly once" do
    course = course_with("Ash")

    apply(courses: Course.where(id: course.id), added: %w[Ash Cedar])

    expect(attached_names(course)).to contain_exactly("Ash", "Cedar")
  end

  it "reports how many courses it updated" do
    courses = Course.where(id: [course_with("Ash").id, course_with("Beech").id])

    expect(apply(courses:, added: %w[Cedar])).to eq(2)
  end

  it "stamps the provider once however many courses it touched" do
    courses = Course.where(id: [course_with("Ash").id, course_with("Beech").id, course_with("Ash").id])

    expect { apply(courses:, added: %w[Cedar]) }.to(change { provider.reload.changed_at })
    expect(provider.reload.changed_at).to be_present
  end

  it "gives every course it updated its own changed_at" do
    one = course_with("Ash")
    two = course_with("Beech")

    apply(courses: Course.where(id: [one.id, two.id]), added: %w[Cedar])

    expect(one.reload.changed_at).not_to eq(two.reload.changed_at)
  end

  it "carries on when one course cannot be updated" do
    good = course_with("Ash")
    bad = course_with("Beech")

    allow(Publish::Schools::UpdateCourseSchoolsService).to receive(:call).and_call_original
    allow(Publish::Schools::UpdateCourseSchoolsService)
      .to receive(:call).with(hash_including(course: bad)).and_raise(ActiveRecord::RecordInvalid)
    allow(Sentry).to receive(:capture_exception)

    expect(apply(courses: Course.where(id: [good.id, bad.id]), added: %w[Cedar])).to eq(1)
    expect(attached_names(good)).to contain_exactly("Ash", "Cedar")
    expect(Sentry).to have_received(:capture_exception)
  end

  it "does not announce a bulk change once per course" do
    FeatureFlag.activate(:course_sites_updated_email_notification)
    allow(NotificationService::CourseSitesUpdated).to receive(:call)

    apply(courses: Course.where(id: course_with("Ash").id), added: %w[Cedar])

    expect(NotificationService::CourseSitesUpdated).not_to have_received(:call)
  end
end
