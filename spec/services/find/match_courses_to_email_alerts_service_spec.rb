# frozen_string_literal: true

require "rails_helper"

module Find
  RSpec.describe MatchCoursesToEmailAlertsService do
    describe ".call" do
      let(:candidate) { create(:candidate) }

      it "enqueues EmailAlertMailerJob for alerts with matching recently published courses" do
        course = create(:course, :published_postgraduate)
        course.enrichments.first.update!(last_published_timestamp_utc: 2.days.ago)

        alert = create(:email_alert, candidate:)

        expect { described_class.call(since: 1.week.ago) }
          .to have_enqueued_job(EmailAlertMailerJob)
          .with(alert.id, [course.id])
      end

      it "does not enqueue a job when no courses were published since the given date" do
        course = create(:course, :published_postgraduate)
        course.enrichments.first.update!(last_published_timestamp_utc: 2.weeks.ago)

        create(:email_alert, candidate:)

        expect { described_class.call(since: 1.week.ago) }
          .not_to have_enqueued_job(EmailAlertMailerJob)
      end

      it "does not enqueue a job for unsubscribed alerts" do
        course = create(:course, :published_postgraduate)
        course.enrichments.first.update!(last_published_timestamp_utc: 2.days.ago)

        alert = create(:email_alert, candidate:)
        alert.unsubscribe!

        expect { described_class.call(since: 1.week.ago) }
          .not_to have_enqueued_job(EmailAlertMailerJob)
      end

      it "does not enqueue a job when matching courses exist but none are recently published" do
        course = create(:course, :published_postgraduate)
        course.enrichments.first.update!(last_published_timestamp_utc: 1.month.ago)

        create(:email_alert, candidate:)

        expect { described_class.call(since: 1.week.ago) }
          .not_to have_enqueued_job(EmailAlertMailerJob)
      end

      it "processes multiple alerts independently" do
        course = create(:course, :published_postgraduate)
        course.enrichments.first.update!(last_published_timestamp_utc: 2.days.ago)

        create(:email_alert, candidate:)
        create(:email_alert, candidate: create(:candidate))

        expect { described_class.call(since: 1.week.ago) }
          .to have_enqueued_job(EmailAlertMailerJob).exactly(2).times
      end

      it "scopes recently published courses to the current recruitment cycle" do
        next_provider = create(:provider, :next_recruitment_cycle)
        next_course = create(:course, :published_postgraduate, provider: next_provider)
        next_course.enrichments.first.update!(last_published_timestamp_utc: 2.days.ago)

        create(:email_alert, candidate:)

        recently_published_query = CourseEnrichment
          .joins(course: :provider)
          .merge(Provider.in_current_cycle)
          .where(status: :published)
          .where("last_published_timestamp_utc > ?", 1.week.ago)

        expect(recently_published_query.pluck(:course_id)).not_to include(next_course.id)
      end

      it "staggers jobs using BatchDelivery over 1 hour" do
        course = create(:course, :published_postgraduate)
        course.enrichments.first.update!(last_published_timestamp_utc: 2.days.ago)

        create(:email_alert, candidate:)

        freeze_time do
          described_class.call(since: 1.week.ago)

          job = ActiveJob::Base.queue_adapter.enqueued_jobs.last
          expect(job["scheduled_at"]).to be_present
        end
      end

      it "uses BatchDelivery with 1 hour stagger and batch size of 100" do
        batch_delivery = instance_double(BatchDelivery)
        allow(BatchDelivery).to receive(:new)
          .with(relation: anything, stagger_over: 1.hour, batch_size: 100)
          .and_return(batch_delivery)
        allow(batch_delivery).to receive(:each)

        described_class.call(since: 1.week.ago)

        expect(BatchDelivery).to have_received(:new)
          .with(relation: anything, stagger_over: 1.hour, batch_size: 100)
      end
    end
  end
end
