require "rails_helper"

describe CourseVacanciesUpdatedEmailMailer, type: :mailer do
  let(:course) { create(:course, :with_accrediting_provider) }
  let(:user) { create(:user) }
  let(:vacancies_filled) { true }
  let(:mail) {
    described_class.course_vacancies_updated_email(
      course: course,
      user: user,
      datetime: DateTime.new(2001, 2, 3, 4, 5, 6),
      vacancies_filled: vacancies_filled,
  )
  }

  before do
    course
    mail
  end

  context "sending an email to a user" do
    it "sends an email with the correct template" do
      expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.course_vacancies_updated_email_template_id)
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

    it "includes the datetime for the withdrawal in the personalisation" do
      expect(mail.govuk_notify_personalisation[:vacancies_updated_datetime]).to eq("4:05am on 3 February 2001")
    end

    it "includes the URL for the course in the personalisation" do
      url = "#{Settings.find_url}" \
        "/course/#{course.provider.provider_code}" \
        "/#{course.course_code}"
      expect(mail.govuk_notify_personalisation[:course_url]).to eq(url)
    end

    describe "vacancies filled" do
      context "vacancies filled is true" do
        it "includes whether vacancies are filled in the personalisation" do
          expect(mail.govuk_notify_personalisation[:vacancies_filled]).to eq("yes")
        end

        it "includes whether vacancies are open in the personalisation" do
          expect(mail.govuk_notify_personalisation[:vacancies_opened]).to eq("no")
        end
      end

      context "vacancies filled is false" do
        let(:vacancies_filled) { false }
        it "includes whether vacancies are filled in the personalisation" do
          expect(mail.govuk_notify_personalisation[:vacancies_filled]).to eq("no")
        end

        it "includes whether vacancies are filled in the personalisation" do
          expect(mail.govuk_notify_personalisation[:vacancies_opened]).to eq("yes")
        end
      end
    end
  end
end
