require "rails_helper"

describe CourseUpdateEmailMailer, type: :mailer do
  let(:course) { create(:course, :with_accrediting_provider, updated_at: DateTime.new(2001, 2, 3, 4, 5, 6)) }
  let(:user) { create(:user) }
  let(:mail) { described_class.course_update_email(course, "name", user) }

  before do
    course
    mail
  end

  context "sending an email to a user" do
    it "sends an email with the correct template" do
      expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.course_update_email_template_id)
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

    it "includes the updated detail in the personalisation" do
      expect(mail.govuk_notify_personalisation[:attribute_changed]).to eq("name")
    end

    it "includes the datetime for the detail update in the personalisation" do
      expect(mail.govuk_notify_personalisation[:attribute_change_datetime]).to eq("4.05 on 3 February 2001")
    end

    it "includes the URL for the course in the personalisation" do
      url = "#{Settings.publish_url}" \
        "/organisations/#{course.provider.provider_code}" \
        "/#{course.provider.recruitment_cycle.year}" \
        "/courses/#{course.course_code}"
      expect(mail.govuk_notify_personalisation[:course_url]).to eq(url)
    end
  end
end
