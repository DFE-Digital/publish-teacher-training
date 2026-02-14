# frozen_string_literal: true

require "rails_helper"

module Find
  RSpec.describe MatchCoursesToEmailAlertsService, "integration" do
    include ActiveJob::TestHelper

    let(:candidate) { create(:candidate) }

    let(:biology) { find_or_create(:secondary_subject, :biology) }
    let(:chemistry) { find_or_create(:secondary_subject, :chemistry) }
    let(:physics) { find_or_create(:secondary_subject, :physics) }
    let(:mathematics) { find_or_create(:secondary_subject, :mathematics) }

    let(:london) { build(:location, :london) }
    let(:manchester) { build(:location, :manchester) }
    let(:edinburgh) { build(:location, :edinburgh) }

    def create_findable_course(name:, subjects:, latitude: nil, longitude: nil, published_at: 2.days.ago, **traits)
      site_attrs = {}
      site_attrs[:latitude] = latitude if latitude
      site_attrs[:longitude] = longitude if longitude

      course = create(
        :course,
        :secondary,
        :open,
        :published,
        name:,
        subjects:,
        infer_subjects?: false,
        site_statuses: [
          build(:site_status, :findable, vac_status: :full_time_vacancies,
                site: build(:site, **site_attrs)),
        ],
        **traits,
      )

      course.enrichments.first.update!(last_published_timestamp_utc: published_at)
      course
    end

    describe "multi-alert matching scenarios" do
      let!(:biology_london) do
        create_findable_course(
          name: "Biology at London",
          subjects: [biology],
          latitude: london.latitude,
          longitude: london.longitude,
        )
      end

      let!(:chemistry_london) do
        create_findable_course(
          name: "Chemistry at London",
          subjects: [chemistry],
          latitude: london.latitude,
          longitude: london.longitude,
        )
      end

      let!(:biology_manchester) do
        create_findable_course(
          name: "Biology at Manchester",
          subjects: [biology],
          latitude: manchester.latitude,
          longitude: manchester.longitude,
        )
      end

      let!(:physics_london_visa) do
        create_findable_course(
          name: "Physics at London (visa)",
          subjects: [physics],
          latitude: london.latitude,
          longitude: london.longitude,
          can_sponsor_skilled_worker_visa: true,
        )
      end

      let!(:maths_old) do
        create_findable_course(
          name: "Maths (published 3 weeks ago)",
          subjects: [mathematics],
          published_at: 3.weeks.ago,
        )
      end

      it "matches a subject-only alert to all recently published courses with that subject" do
        alert = create(:email_alert, candidate:, subjects: %w[C1])

        expect { described_class.call(since: 1.week.ago) }
          .to have_enqueued_job(EmailAlertMailerJob).once

        jobs = ActiveJob::Base.queue_adapter.enqueued_jobs
        job = jobs.last
        course_ids = job["arguments"].second
        expect(course_ids).to contain_exactly(biology_london.id, biology_manchester.id)
      end

      it "matches a location-based alert only to courses within radius" do
        alert = create(:email_alert, candidate:,
                        subjects: %w[C1],
                        latitude: london.latitude,
                        longitude: london.longitude,
                        radius: 50,
                        location_name: "London",
                        search_attributes: { "location" => "London", "radius" => "50" })

        expect { described_class.call(since: 1.week.ago) }
          .to have_enqueued_job(EmailAlertMailerJob).once

        jobs = ActiveJob::Base.queue_adapter.enqueued_jobs
        job = jobs.last
        course_ids = job["arguments"].second
        # Manchester is ~160 miles from London, so only London Biology matches
        expect(course_ids).to contain_exactly(biology_london.id)
      end

      it "matches a visa-sponsorship alert only to courses offering visa sponsorship" do
        alert = create(:email_alert, candidate:,
                        search_attributes: { "can_sponsor_visa" => "true" })

        expect { described_class.call(since: 1.week.ago) }
          .to have_enqueued_job(EmailAlertMailerJob).once

        jobs = ActiveJob::Base.queue_adapter.enqueued_jobs
        job = jobs.last
        course_ids = job["arguments"].second
        expect(course_ids).to contain_exactly(physics_london_visa.id)
      end

      it "does not match courses published before the since date" do
        alert = create(:email_alert, candidate:, subjects: %w[G1])

        expect { described_class.call(since: 1.week.ago) }
          .not_to have_enqueued_job(EmailAlertMailerJob)
      end

      it "one course can match multiple alerts from different candidates" do
        alert_a = create(:email_alert, candidate:, subjects: %w[C1])
        alert_b = create(:email_alert, candidate: create(:candidate), subjects: %w[C1])

        expect { described_class.call(since: 1.week.ago) }
          .to have_enqueued_job(EmailAlertMailerJob).exactly(2).times
      end

      it "sends different courses to different alerts based on their criteria" do
        biology_alert = create(:email_alert, candidate:, subjects: %w[C1])
        chemistry_alert = create(:email_alert, candidate: create(:candidate), subjects: %w[F1])

        described_class.call(since: 1.week.ago)

        jobs = ActiveJob::Base.queue_adapter.enqueued_jobs.select { |j| j["job_class"] == "EmailAlertMailerJob" }
        expect(jobs.size).to eq(2)

        biology_job = jobs.find { |j| j["arguments"].first == biology_alert.id }
        chemistry_job = jobs.find { |j| j["arguments"].first == chemistry_alert.id }

        expect(biology_job["arguments"].second).to contain_exactly(biology_london.id, biology_manchester.id)
        expect(chemistry_job["arguments"].second).to contain_exactly(chemistry_london.id)
      end

      it "skips unsubscribed alerts entirely" do
        alert = create(:email_alert, candidate:, subjects: %w[C1])
        alert.unsubscribe!

        expect { described_class.call(since: 1.week.ago) }
          .not_to have_enqueued_job(EmailAlertMailerJob)
      end

      it "an alert with no matching recently published courses gets no job" do
        create(:email_alert, candidate:, subjects: %w[22]) # Spanish — no Spanish courses exist

        expect { described_class.call(since: 1.week.ago) }
          .not_to have_enqueued_job(EmailAlertMailerJob)
      end
    end

    describe "re-published courses" do
      it "includes courses that were re-published within the since window" do
        course = create_findable_course(
          name: "Re-published Biology",
          subjects: [biology],
          published_at: 1.month.ago,
        )

        # Simulate re-publish: update the enrichment timestamp
        course.enrichments.first.update!(last_published_timestamp_utc: 1.day.ago)

        alert = create(:email_alert, candidate:, subjects: %w[C1])

        expect { described_class.call(since: 1.week.ago) }
          .to have_enqueued_job(EmailAlertMailerJob).once

        jobs = ActiveJob::Base.queue_adapter.enqueued_jobs
        job = jobs.last
        expect(job["arguments"].second).to contain_exactly(course.id)
      end
    end

    describe "combined filters" do
      it "matches only courses satisfying all alert criteria simultaneously" do
        biology_visa = create_findable_course(
          name: "Biology with visa",
          subjects: [biology],
          can_sponsor_skilled_worker_visa: true,
        )

        biology_no_visa = create_findable_course(
          name: "Biology no visa",
          subjects: [biology],
          can_sponsor_skilled_worker_visa: false,
        )

        alert = create(:email_alert, candidate:,
                        subjects: %w[C1],
                        search_attributes: { "can_sponsor_visa" => "true" })

        expect { described_class.call(since: 1.week.ago) }
          .to have_enqueued_job(EmailAlertMailerJob).once

        jobs = ActiveJob::Base.queue_adapter.enqueued_jobs
        job = jobs.last
        expect(job["arguments"].second).to contain_exactly(biology_visa.id)
      end
    end

    describe "edge cases" do
      it "handles an alert with no subjects and no location (broad match)" do
        course = create_findable_course(name: "Any course", subjects: [biology])

        alert = create(:email_alert, candidate:)

        expect { described_class.call(since: 1.week.ago) }
          .to have_enqueued_job(EmailAlertMailerJob).once
      end

      it "handles zero active alerts gracefully" do
        create_findable_course(name: "Orphan course", subjects: [biology])

        expect { described_class.call(since: 1.week.ago) }
          .not_to have_enqueued_job(EmailAlertMailerJob)
      end

      it "handles zero recently published courses gracefully" do
        create(:email_alert, candidate:, subjects: %w[C1])

        expect { described_class.call(since: 1.week.ago) }
          .not_to have_enqueued_job(EmailAlertMailerJob)
      end
    end
  end
end
