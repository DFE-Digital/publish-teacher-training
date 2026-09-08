# frozen_string_literal: true

require "rails_helper"

describe BulkUpdateCourseSchoolsJob do
  let(:provider) { create(:provider) }
  let(:course) { create(:course, provider:, sites: []) }
  let(:other_course) { create(:course, provider:, sites: []) }

  def result(updated: [], failed: [])
    Publish::Schools::BulkUpdate::Apply::Result.new(updated_ids: updated, failed_ids: failed)
  end

  def stub_apply(returning)
    allow(Publish::Schools::BulkUpdate::Apply).to receive(:call).and_return(returning)
  end

  it "applies the change to the courses it was given" do
    stub_apply(result(updated: [course.id]))

    described_class.new.perform([course.id], %w[added], %w[removed])

    expect(Publish::Schools::BulkUpdate::Apply).to have_received(:call) do |courses:, added_uuids:, removed_uuids:|
      expect(courses).to contain_exactly(course)
      expect(added_uuids).to eq(%w[added])
      expect(removed_uuids).to eq(%w[removed])
    end
  end

  it "ignores a course that was deleted while the job was waiting" do
    stub_apply(result)

    described_class.new.perform([course.id, course.id + 1_000], [], [])

    expect(Publish::Schools::BulkUpdate::Apply).to have_received(:call) do |courses:, **|
      expect(courses).to contain_exactly(course)
    end
  end

  it "asks for nothing more when every course was updated" do
    stub_apply(result(updated: [course.id]))
    allow(described_class).to receive(:perform_in)

    described_class.new.perform([course.id], [], [])

    expect(described_class).not_to have_received(:perform_in)
  end

  describe "when some courses could not be updated" do
    before { stub_apply(result(updated: [course.id], failed: [other_course.id])) }

    it "comes back for the ones that failed, and only those" do
      allow(described_class).to receive(:perform_in)

      described_class.new.perform([course.id, other_course.id], %w[a], %w[b], 1)

      expect(described_class).to have_received(:perform_in)
        .with(kind_of(ActiveSupport::Duration), [other_course.id], %w[a], %w[b], 2)
    end

    it "gives up once it has tried enough times" do
      allow(described_class).to receive(:perform_in)
      allow(Sentry).to receive(:capture_message)

      described_class.new.perform([other_course.id], [], [], described_class::MAX_ATTEMPTS)

      expect(described_class).not_to have_received(:perform_in)
      expect(Sentry).to have_received(:capture_message)
    end

    # One report naming every course still outstanding, rather than one per
    # course per attempt.
    it "reports what was left when it gave up" do
      allow(Sentry).to receive(:capture_message)

      described_class.new.perform([other_course.id], [], [], described_class::MAX_ATTEMPTS)

      expect(Sentry).to have_received(:capture_message) do |_message, extra:|
        expect(extra[:course_ids]).to eq([other_course.id])
      end
    end
  end
end
