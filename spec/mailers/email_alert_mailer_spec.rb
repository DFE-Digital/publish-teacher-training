# frozen_string_literal: true

require "rails_helper"

describe EmailAlertMailer do
  let(:candidate) { create(:candidate) }
  let(:email_alert) do
    create(:email_alert, candidate:, subjects: %w[C1], location_name: "Manchester", radius: 10)
  end
  let(:courses) do
    [
      create(:course, :published, :with_accrediting_provider),
      create(:course, :published, :with_accrediting_provider),
    ]
  end
  let(:mail) { described_class.weekly_digest(email_alert, courses) }

  before do
    subject_area = find_or_create(:subject_area, :secondary)
    Subject.find_or_create_by!(subject_code: "C1") do |s|
      s.subject_name = "Biology"
      s.type = "SecondarySubject"
      s.subject_area = subject_area
    end
    mail
  end

  it "sends an email with the correct template" do
    expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.email_alert_weekly_digest_template_id)
  end

  it "sends an email to the candidate's email address" do
    expect(mail.to).to eq([candidate.email_address])
  end

  it "includes the title in the personalisation" do
    expect(mail.govuk_notify_personalisation[:title]).to eq("Biology courses within 10 miles of Manchester")
  end

  it "includes the course count in the personalisation" do
    expect(mail.govuk_notify_personalisation[:course_count]).to eq("2")
  end

  it "includes the course list in the personalisation" do
    courses.each do |course|
      expect(mail.govuk_notify_personalisation[:course_list]).to include(course.name)
      expect(mail.govuk_notify_personalisation[:course_list]).to include(course.provider.provider_name)
      expect(mail.govuk_notify_personalisation[:course_list]).to include(course.course_code)
    end
  end

  it "limits the course list to 20 courses" do
    many_courses = create_list(:course, 25, :published, :with_accrediting_provider)
    mail = described_class.weekly_digest(email_alert, many_courses)

    lines = mail.govuk_notify_personalisation[:course_list].split("\n")
    expect(lines.size).to eq(20)
  end

  it "includes a valid unsubscribe URL in the personalisation" do
    url = mail.govuk_notify_personalisation[:unsubscribe_url]
    expect(url).to include("/email-alerts/")
    expect(url).to include("/unsubscribe")
  end

  context "with multiple subjects and no location" do
    let(:email_alert) do
      create(:email_alert, candidate:, subjects: %w[C1 F1], location_name: nil, radius: nil)
    end

    before do
      subject_area = find_or_create(:subject_area, :secondary)
      Subject.find_or_create_by!(subject_code: "F1") do |s|
        s.subject_name = "Chemistry"
        s.type = "SecondarySubject"
        s.subject_area = subject_area
      end
    end

    it "generates the correct title" do
      mail = described_class.weekly_digest(email_alert, courses)
      expect(mail.govuk_notify_personalisation[:title]).to eq("Biology and Chemistry courses in England")
    end
  end

  context "with no subjects and no location" do
    let(:email_alert) do
      create(:email_alert, candidate:, subjects: [], location_name: nil, radius: nil)
    end

    it "falls back to a generic title" do
      mail = described_class.weekly_digest(email_alert, courses)
      expect(mail.govuk_notify_personalisation[:title]).to eq("your saved search")
    end
  end
end
