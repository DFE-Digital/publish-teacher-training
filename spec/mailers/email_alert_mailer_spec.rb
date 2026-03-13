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

  it "includes the subject in the personalisation" do
    expect(mail.govuk_notify_personalisation[:subject]).to be_present
  end

  it "includes the body in the personalisation" do
    body = mail.govuk_notify_personalisation[:body]
    courses.each do |course|
      expect(body).to include(course.name)
      expect(body).to include(course.provider.provider_name)
      expect(body).to include(course.course_code)
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

  it "limits the course list to 20 courses" do
    many_courses = create_list(:course, 25, :published, :with_accrediting_provider)
    mail = described_class.weekly_digest(email_alert, many_courses)

    body = mail.govuk_notify_personalisation[:body]
    many_courses.first(20).each do |course|
      expect(body).to include(course.course_code)
    end
    expect(body).to include("and 5 more")
  end

  describe "sanitisation of user-controlled input" do
    context "when location_name contains Notify markdown link injection" do
      let(:email_alert) do
        create(:email_alert, candidate:, subjects: [], location_name: "London](https://evil.com) [Click here", radius: 10)
      end
      let(:courses) { [create(:course, :published, :with_accrediting_provider)] }

      it "strips markdown link characters from the subject line" do
        mail = described_class.weekly_digest(email_alert, courses)
        subject_line = mail.govuk_notify_personalisation[:subject]
        expect(subject_line).not_to include("](")
        expect(subject_line).not_to include("[Click")
        expect(subject_line).to include("Londonhttps://evil.com Click here")
      end

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

      it "truncates the location in the subject line" do
        mail = described_class.weekly_digest(email_alert, courses)
        subject_line = mail.govuk_notify_personalisation[:subject]
        expect(subject_line.length).to be <= 300
        expect(subject_line).to include("A" * 100)
        expect(subject_line).to include("...")
      end

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
        expect(body).to include("Provider: Evil Corphttps://evil.com pwned")
      end
    end
  end

  describe "subject line variants" do
    context "with 1 course, 1 subject, no location" do
      let(:email_alert) do
        create(:email_alert, candidate:, subjects: %w[C1], location_name: nil, radius: nil)
      end
      let(:courses) { [create(:course, :published, :with_accrediting_provider)] }

      it "uses the provider and subject name" do
        mail = described_class.weekly_digest(email_alert, courses)
        provider_name = courses.first.provider.provider_name
        expect(mail.govuk_notify_personalisation[:subject]).to eq(
          "#{provider_name} has added a new Biology course",
        )
      end
    end

    context "with 1 course, no subject, no location" do
      let(:email_alert) do
        create(:email_alert, candidate:, subjects: [], location_name: nil, radius: nil)
      end
      let(:courses) { [create(:course, :published, :with_accrediting_provider)] }

      it "uses the provider name with generic text" do
        mail = described_class.weekly_digest(email_alert, courses)
        provider_name = courses.first.provider.provider_name
        expect(mail.govuk_notify_personalisation[:subject]).to eq(
          "#{provider_name} is looking for trainee teachers",
        )
      end
    end

    context "with 1 course, 1 subject, with location" do
      let(:email_alert) do
        create(:email_alert, candidate:, subjects: %w[C1], location_name: "Manchester", radius: 10)
      end
      let(:courses) { [create(:course, :published, :with_accrediting_provider)] }

      it "uses the subject and location" do
        mail = described_class.weekly_digest(email_alert, courses)
        expect(mail.govuk_notify_personalisation[:subject]).to eq(
          "A new Biology course has been added near Manchester",
        )
      end
    end

    context "with 1 course, no subject, with location" do
      let(:email_alert) do
        create(:email_alert, candidate:, subjects: [], location_name: "Manchester", radius: 10)
      end
      let(:courses) { [create(:course, :published, :with_accrediting_provider)] }

      it "uses the location with generic text" do
        mail = described_class.weekly_digest(email_alert, courses)
        expect(mail.govuk_notify_personalisation[:subject]).to eq(
          "A new teacher training course in Manchester meets your criteria",
        )
      end
    end

    context "with multiple courses, 1 subject" do
      let(:email_alert) do
        create(:email_alert, candidate:, subjects: %w[C1], location_name: nil, radius: nil)
      end

      it "uses the subject name" do
        mail = described_class.weekly_digest(email_alert, courses)
        expect(mail.govuk_notify_personalisation[:subject]).to eq(
          "A new Biology course has been added to Find teacher training courses",
        )
      end
    end

    context "with multiple courses, no subject" do
      let(:email_alert) do
        create(:email_alert, candidate:, subjects: [], location_name: nil, radius: nil)
      end

      it "uses the count" do
        mail = described_class.weekly_digest(email_alert, courses)
        expect(mail.govuk_notify_personalisation[:subject]).to eq(
          "2 new teacher training courses meet your criteria",
        )
      end
    end

    context "with 1 course, multiple subjects, no location" do
      let(:email_alert) do
        create(:email_alert, candidate:, subjects: %w[C1 F1], location_name: nil, radius: nil)
      end
      let(:courses) { [create(:course, :published, :with_accrediting_provider)] }

      before do
        subject_area = find_or_create(:subject_area, :secondary)
        Subject.find_or_create_by!(subject_code: "F1") do |s|
          s.subject_name = "Chemistry"
          s.type = "SecondarySubject"
          s.subject_area = subject_area
        end
      end

      it "uses the provider name with generic text" do
        mail = described_class.weekly_digest(email_alert, courses)
        provider_name = courses.first.provider.provider_name
        expect(mail.govuk_notify_personalisation[:subject]).to eq(
          "#{provider_name} is looking for trainee teachers",
        )
      end
    end
  end
end
