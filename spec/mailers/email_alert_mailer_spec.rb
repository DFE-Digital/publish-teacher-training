# frozen_string_literal: true

require "rails_helper"

describe EmailAlertMailer do
  let(:candidate) { create(:candidate) }
  let(:email_alert) do
    create(:email_alert, candidate:, subjects: %w[C1], location_name: "Manchester", radius: 10)
  end
  let(:courses) do
    create_list(:course, 2, :published, :with_accrediting_provider)
  end
  let(:mail) { described_class.weekly_digest(email_alert, courses) }

  before do
    subject_area = find_or_create(:subject_area, :secondary)
    Subject.find_or_create_by!(subject_code: "C1") do |subject|
      subject.subject_name = "Biology"
      subject.type = "SecondarySubject"
      subject.subject_area = subject_area
    end
    mail
  end

  it "sends an email with the correct template" do
    expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.email_alert_weekly_digest_template_id)
  end

  it "sends an email to the candidate's email address" do
    expect(mail.to).to eq([candidate.email_address])
  end

  it "includes the subject in the personalisation" do
    expect(mail.govuk_notify_personalisation[:subject]).to be_present
  end

  it "includes provider name and course name with code in the body" do
    body = mail.govuk_notify_personalisation[:body]
    courses.each do |course|
      expect(body).to include(course.provider.provider_name)
      expect(body).to include("#{course.name} (#{course.course_code})")
    end
  end

  it "includes an unsubscribe link in the body" do
    body = mail.govuk_notify_personalisation[:body]
    expect(body).to include("Unsubscribe here")
    expect(body).to include("/unsubscribe")
  end

  it "includes the criteria section in the body" do
    body = mail.govuk_notify_personalisation[:body]
    expect(body).to include("Your email alert criteria")
    expect(body).to include("Subject")
    expect(body).to include("Biology")
  end

  it "includes links to GIT resources in the body" do
    body = mail.govuk_notify_personalisation[:body]
    expect(body).to include("Find out how to choose a course")
    expect(body).to include("Get a free teacher training adviser")
  end

  context "with course limit stubbed" do
    before { stub_const("EmailAlertMailer::COURSE_LIMIT", 2) }

    it "limits the course list to the COURSE_LIMIT" do
      many_courses = create_list(:course, 4, :published, :with_accrediting_provider)
      mail = described_class.weekly_digest(email_alert, many_courses)

      body = mail.govuk_notify_personalisation[:body]
      many_courses.first(2).each do |course|
        expect(body).to include(course.course_code)
      end
      many_courses.last(2).each do |course|
        expect(body).not_to include(course.course_code)
      end
    end

    it "shows view more link when courses are truncated" do
      many_courses = create_list(:course, 4, :published, :with_accrediting_provider)
      mail = described_class.weekly_digest(email_alert, many_courses)

      body = mail.govuk_notify_personalisation[:body]
      expect(body).to include("View more courses that meet your criteria on Find teacher training courses.")
    end

    it "does not show view more link when courses fit within the limit" do
      few_courses = create_list(:course, 2, :published, :with_accrediting_provider)
      mail = described_class.weekly_digest(email_alert, few_courses)

      body = mail.govuk_notify_personalisation[:body]
      expect(body).not_to include("View more courses")
    end

    it "includes order=newest_course in search URL when courses are truncated" do
      many_courses = create_list(:course, 4, :published, :with_accrediting_provider)
      mail = described_class.weekly_digest(email_alert, many_courses)

      body = mail.govuk_notify_personalisation[:body]
      expect(body).to include("order=newest_course")
    end

    it "does not include order=newest_course in search URL when courses fit within the limit" do
      few_courses = create_list(:course, 2, :published, :with_accrediting_provider)
      mail = described_class.weekly_digest(email_alert, few_courses)

      body = mail.govuk_notify_personalisation[:body]
      expect(body).not_to include("order=newest_course")
    end
  end

  describe "sanitisation of user-controlled input" do
    context "when location_name contains Notify markdown link injection" do
      let(:email_alert) do
        create(:email_alert, candidate:, subjects: [], location_name: "London](https://evil.com) [Click here", radius: 10)
      end
      let(:courses) { [create(:course, :published, :with_accrediting_provider)] }

      it "strips markdown link characters from the body criteria" do
        mail = described_class.weekly_digest(email_alert, courses)
        body = mail.govuk_notify_personalisation[:body]
        expect(body).not_to include("](https://evil.com)")
        expect(body).not_to include("[Click here")
        expect(body).to include("Within 10 miles of Londonhttps://evil.com Click here")
      end
    end

    context "when location_name contains Notify markdown heading injection" do
      let(:email_alert) do
        create(:email_alert, candidate:, subjects: [], location_name: "London\n# Injected heading", radius: 10)
      end
      let(:courses) { [create(:course, :published, :with_accrediting_provider)] }

      it "strips newlines and heading markers from the body" do
        mail = described_class.weekly_digest(email_alert, courses)
        body = mail.govuk_notify_personalisation[:body]
        expect(body).not_to include("# Injected heading")
        expect(body).to include("London Injected heading")
      end
    end

    context "when location_name is excessively long" do
      let(:email_alert) do
        create(:email_alert, candidate:, subjects: [], location_name: "A" * 1000, radius: 10)
      end
      let(:courses) { [create(:course, :published, :with_accrediting_provider)] }

      it "truncates the location in the body criteria" do
        mail = described_class.weekly_digest(email_alert, courses)
        body = mail.govuk_notify_personalisation[:body]
        expect(body).not_to include("A" * 201)
        expect(body).to include("A" * 100)
        expect(body).to include("...")
      end
    end

    context "when search_attributes contain markdown injection via provider_name" do
      let(:email_alert) do
        create(
          :email_alert,
          candidate:,
          subjects: [],
          location_name: nil,
          radius: nil,
          search_attributes: { "provider_name" => "Evil Corp](https://evil.com) [pwned" },
        )
      end
      let(:courses) { [create(:course, :published, :with_accrediting_provider)] }

      it "strips markdown link characters from criteria values in the body" do
        mail = described_class.weekly_digest(email_alert, courses)
        body = mail.govuk_notify_personalisation[:body]
        expect(body).not_to include("](https://evil.com)")
        expect(body).not_to include("[pwned")
        expect(body).to have_content("Provider: Evil Corphttps://evil.com pwned", normalize_ws: true)
      end
    end
  end

  describe "subject line" do
    context "with 1 course" do
      let(:courses) { [create(:course, :published, :with_accrediting_provider)] }

      it "uses the singular subject line" do
        mail = described_class.weekly_digest(email_alert, courses)
        expect(mail.govuk_notify_personalisation[:subject]).to eq(
          "A new teacher training course meets your criteria",
        )
      end
    end

    context "with multiple courses" do
      it "uses the count in the subject line" do
        mail = described_class.weekly_digest(email_alert, courses)
        expect(mail.govuk_notify_personalisation[:subject]).to eq(
          "2 new teacher training courses meet your criteria",
        )
      end
    end

    context "with more courses than the limit" do
      before { stub_const("EmailAlertMailer::COURSE_LIMIT", 2) }

      let(:many_courses) { create_list(:course, 4, :published, :with_accrediting_provider) }

      it "uses the total count including truncated courses" do
        mail = described_class.weekly_digest(email_alert, many_courses)
        expect(mail.govuk_notify_personalisation[:subject]).to eq(
          "4 new teacher training courses meet your criteria",
        )
      end
    end
  end

  describe "body intro" do
    context "with 1 course" do
      let(:courses) { [create(:course, :published, :with_accrediting_provider)] }

      it "uses the singular intro" do
        mail = described_class.weekly_digest(email_alert, courses)
        body = mail.govuk_notify_personalisation[:body]
        expect(body).to include("A new teacher training course has recently been published that meets your criteria.")
      end
    end

    context "with multiple courses" do
      it "uses the count in the intro" do
        mail = described_class.weekly_digest(email_alert, courses)
        body = mail.govuk_notify_personalisation[:body]
        expect(body).to include("2 teacher training courses have recently been published that meet your criteria.")
      end
    end
  end
end
