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

  it_behaves_like "a job routed to Solid Queue", queue: "default" do
    let(:solid_queue_job_args) { [[1], %w[added], %w[removed]] }
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

    expect { described_class.new.perform([course.id], [], []) }.not_to have_enqueued_job(described_class)
  end

  it "comes back for the whole change when the database connection drops" do
    allow(Publish::Schools::BulkUpdate::Apply).to receive(:call).and_raise(ActiveRecord::ConnectionNotEstablished)

    expect { described_class.perform_now([course.id], %w[a], %w[b]) }
      .to have_enqueued_job(described_class).with([course.id], %w[a], %w[b])
  end

  describe "when some courses could not be updated" do
    before { stub_apply(result(updated: [course.id], failed: [other_course.id])) }

    it "comes back for the ones that failed, and only those" do
      freeze_time

      expect { described_class.new.perform([course.id, other_course.id], %w[a], %w[b], 1) }
        .to have_enqueued_job(described_class)
        .with([other_course.id], %w[a], %w[b], 2)
        .at(described_class::RETRY_AFTER.from_now)
    end

    it "gives up once it has tried enough times" do
      allow(Sentry).to receive(:capture_message)

      expect { described_class.new.perform([other_course.id], [], [], described_class::MAX_ATTEMPTS) }
        .not_to have_enqueued_job(described_class)
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
