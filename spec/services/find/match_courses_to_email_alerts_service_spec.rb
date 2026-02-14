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

        alert1 = create(:email_alert, candidate:)
        alert2 = create(:email_alert, candidate: create(:candidate))

        expect { described_class.call(since: 1.week.ago) }
          .to have_enqueued_job(EmailAlertMailerJob).exactly(2).times
      end
    end
  end
end
