require "rails_helper"

describe CoursePublishEmailMailer, type: :mailer do
  let(:course) { create(:course, :with_accrediting_provider, created_at: DateTime.new(2001, 2, 3, 4, 5, 6)) }
  let(:user) { create(:user) }
  let(:mail) { described_class.course_publish_email(course, user) }

  before do
    course
    mail
  end

  context "sending an email to a user" do
    it "sends an email with the correct template" do
      expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.course_publish_email_template_id)
    end

    it "sends an email to the correct email address" do
      expect(mail.to).to eq([user.email])
    end

    it "includes the provider name in the personalisation" do
      expect(mail.govuk_notify_personalisation[:provider_name]).to eq(course.provider.provider_name)
    end

    it "includes the course name in the personalisation" do
      expect(mail.govuk_notify_personalisation[:course_name]).to eq(course.name)
    end

    it "includes the course code in the personalisation" do
      expect(mail.govuk_notify_personalisation[:course_code]).to eq(course.course_code)
    end

    it "includes the course description in the personalisation" do
      expect(mail.govuk_notify_personalisation[:course_description]).to eq(course.description)
    end

    it "includes the course funding type in the personalisation" do
      expect(mail.govuk_notify_personalisation[:course_funding_type]).to eq(course.funding_type)
    end

    it "includes the datetime for the creation in the personalisation" do
      expect(mail.govuk_notify_personalisation[:create_course_datetime]).to eq("4:05am on 3 February 2001")
    end

    it "includes the URL for the course in the personalisation" do
      url = "#{Settings.find_url}" \
        "/course/#{course.provider.provider_code}" \
        "/#{course.course_code}"
      expect(mail.govuk_notify_personalisation[:course_url]).to eq(url)
    end
  end
end
