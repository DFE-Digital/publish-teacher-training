require "rails_helper"

describe CourseSubjectsUpdatedEmailMailer, type: :mailer do
  let(:previous_subject) { build(:primary_subject, :primary_with_english) }
  let(:course) { build(:course, :with_accrediting_provider, name: updated_course_name, updated_at: DateTime.new(2001, 2, 3, 4, 5, 6), subjects: [updated_subject]) }
  let(:user) { build(:user) }
  let(:updated_subject) { build(:primary_subject, :primary_with_mathematics) }
  let(:previous_course_name) { "primary with English" }
  let(:updated_course_name) { "Primary with Mathematics" }
  let(:mail) do
    described_class.course_subjects_updated_email(
      course: course,
      previous_subject_names: [previous_subject.subject_name],
      updated_subject_names: [updated_subject.subject_name],
      previous_course_name: previous_course_name,
      updated_course_name: updated_course_name,
      recipient: user,
      )
  end

  describe "sending an email to a user" do
    before do
      course
      mail
    end

    it "sends an email with the correct template" do
      expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.course_subjects_updated_email_template_id)
    end

    it "sends an email to the correct email address" do
      expect(mail.to).to eq([user.email])
    end

    it "includes the course code in the personalisation" do
      expect(mail.govuk_notify_personalisation[:course_code]).to eq(course.course_code)
    end

    it "includes the provider name in the personalisation" do
      expect(mail.govuk_notify_personalisation[:provider_name]).to eq(course.provider.provider_name)
    end

    it "includes the datetime for the detail update in the personalisation" do
      expect(mail.govuk_notify_personalisation[:subject_change_datetime]).to eq("4:05am on 3 February 2001")
    end

    context "course has been updated with one subject" do
      it "includes the updated subject" do
        expect(mail.govuk_notify_personalisation[:updated_subjects]).to eq(updated_subject.subject_name)
      end

      it "includes the previous subject" do
        expect(mail.govuk_notify_personalisation[:previous_subjects]).to eq(previous_subject.subject_name)
      end

      it "includes the updated course name" do
        expect(mail.govuk_notify_personalisation[:updated_course_name]).to eq(updated_course_name)
      end

      it "includes the previous course name" do
        expect(mail.govuk_notify_personalisation[:previous_course_name]).to eq(previous_course_name)
      end
    end

    context "course has been updated with two subjects" do
      let(:course) { build(:course, :with_accrediting_provider, name: updated_course_name, updated_at: DateTime.new(2001, 2, 3, 4, 5, 6), subjects: [updated_subject]) }
      let(:user) { build(:user) }
      let(:first_updated_subject) { build(:secondary_subject, :mathematics) }
      let(:second_updated_subject) { build(:secondary_subject, :biology) }
      let(:previous_subject) { build(:secondary_subject, :mathematics) }
      let(:previous_course_name) { "Mathematics" }
      let(:updated_course_name) { "Mathematics with Biology" }
      let(:mail) do
        described_class.course_subjects_updated_email(
          course: course,
          previous_subject_names: [previous_subject.subject_name],
          updated_subject_names: [first_updated_subject.subject_name, second_updated_subject.subject_name],
          previous_course_name: previous_course_name,
          updated_course_name: updated_course_name,
          recipient: user,
          )
      end

      it "includes the updated subjects" do
        expect(mail.govuk_notify_personalisation[:updated_subjects]).to eq("Mathematics, Biology")
      end
    end
  end
end
