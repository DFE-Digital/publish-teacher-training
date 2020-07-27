require "rails_helper"

describe CourseUpdateEmailMailer, type: :mailer do
  let(:course) { create(:course, :with_accrediting_provider, updated_at: DateTime.new(2001, 2, 3, 4, 5, 6)) }
  let(:user) { create(:user) }

  context "sending an email to a user" do
    let(:mail) do
      described_class.course_update_email(
        course: course,
        attribute_name: "qualification",
        original_value: "original",
        updated_value: "updated",
        recipient: user,
        )
    end

    before do
      course
      mail

      allow(CourseAttributeFormatterService)
        .to receive(:call)
              .with(name: "qualification", value: "original")
              .and_return("ORIGINAL")

      allow(CourseAttributeFormatterService)
        .to receive(:call)
              .with(name: "qualification", value: "updated")
              .and_return("UPDATED")
    end

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

    it "includes the course description in the personalisation" do
      expect(mail.govuk_notify_personalisation[:course_description]).to eq(course.description)
    end

    it "includes the course funding type in the personalisation" do
      expect(mail.govuk_notify_personalisation[:course_funding_type]).to eq(course.funding_type)
    end

    it "includes the updated detail in the personalisation" do
      expect(mail.govuk_notify_personalisation[:attribute_changed]).to eq("outcome")
    end

    it "includes the datetime for the detail update in the personalisation" do
      expect(mail.govuk_notify_personalisation[:attribute_change_datetime]).to eq("4:05am on 3 February 2001")
    end

    it "includes the original value" do
      expect(mail.govuk_notify_personalisation[:original_value]).to eq("ORIGINAL")
    end

    it "includes the updated value" do
      expect(mail.govuk_notify_personalisation[:updated_value]).to eq("UPDATED")
    end

    it "includes the URL for the course in the personalisation" do
      url = "#{Settings.find_url}" \
        "/course/#{course.provider.provider_code}" \
        "/#{course.course_code}"
      expect(mail.govuk_notify_personalisation[:course_url]).to eq(url)
    end
  end

  context "study mode is updated" do
    study_mode_update_scenarios = [
      {
         original_value: "full time",
         updated_value: "part time",
       },
      {
        original_value: "part time",
        updated_value: "full time",
      },
      {
        original_value: "part time",
        updated_value: "full or part time",
      },
      {
        original_value: "full time",
        updated_value: "full or part time",
      },
      {
        original_value: "full or part time",
        updated_value: "full time",
      },
      {
        original_value: "full or part time",
        updated_value: "part time",
      },
    ]

    study_mode_update_scenarios.each do |scenario|
      context "study mode is updated to #{scenario[:updated_value]}" do
        let(:mail) do
          described_class.course_update_email(
            course: course,
            attribute_name: "study_mode",
            original_value: scenario[:original_value],
            updated_value: scenario[:updated_value],
            recipient: user,
            )
        end

        before do
          allow(CourseAttributeFormatterService)
            .to receive(:call)
                  .with(name: "study_mode", value: scenario[:original_value])
                  .and_return("ORIGINAL")

          allow(CourseAttributeFormatterService)
            .to receive(:call)
                  .with(name: "study_mode", value: scenario[:updated_value])
                  .and_return("UPDATED")
        end

        it "includes the updated detail in the personalisation" do
          expect(mail.govuk_notify_personalisation[:attribute_changed]).to eq("study mode")
        end
      end
    end
  end

  context "course name is updated" do
    let(:previous_name) { course.name }
    let(:mail) do
      course.name = "new course"
      described_class.course_update_email(
        course: course,
        attribute_name: "name",
        original_value: previous_name,
        updated_value: "new course",
        recipient: user,
        )
    end

    before do
      allow(CourseAttributeFormatterService)
        .to receive(:call)
              .with(name: "name", value: previous_name)
              .and_return("ORIGINAL")

      allow(CourseAttributeFormatterService)
        .to receive(:call)
              .with(name: "name", value: "new course")
              .and_return("UPDATED")
    end

    it "includes the original course name in the personalisation" do
      expect(mail.govuk_notify_personalisation[:course_name]).to eq(previous_name)
    end
  end
end
