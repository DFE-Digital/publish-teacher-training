require "rails_helper"

describe Courses::PublishService do
  describe ".call" do
    describe "create course notification emails" do
      let(:provider) { create(:provider) }
      let(:accrediting_provider) { create(:provider, :accredited_body) }
      let(:organisation) { create(:organisation, providers: [provider]) }
      let(:site_status) { create(:site_status, :findable) }
      let(:user_one) { create(:user, organisations: [organisation]) }
      let(:user_two) { create(:user, organisations: [organisation]) }

      let(:course) do
        create(
          :course,
          provider: provider,
          accrediting_provider_code: accrediting_provider.provider_code,
          age_range_in_years: "11_to_15",
          qualification: "pgce_with_qts",
          study_mode: "full_time",
          site_statuses: [site_status],
          maths: :equivalence_test,
          english: :equivalence_test,
        )
      end

      let(:subject) { Courses::PublishService }

      let(:mail_spy) { spy }
      let(:mailer_spy) { spy(course_create_email: mail_spy) }

      before do
        stub_const("CourseCreateEmailMailer", mailer_spy)
      end

      context "a self-accredited course" do
        let(:course) { create(:course, :self_accredited, provider: accrediting_provider) }
        let(:user_notification_one) do
          create(
            :user_notification,
            user_id: user_one.id,
            provider_code: accrediting_provider.provider_code,
            course_create: true,
          )
        end

        let(:user_notification_two) do
          create(
            :user_notification,
            user_id: user_one.id,
            provider_code: accrediting_provider.provider_code,
            course_create: false,
          )
        end
        before do
          user_notification_one
          user_notification_two
        end

        it "does not send a notification" do
          subject.call(course: course)

          expect(mailer_spy).not_to have_received(:course_create_email)
        end
      end

      context "a non self-accredited course" do
        context "with no users with notifications enabled" do
          it "does nothing" do
            subject.call(course: course)

            expect(mailer_spy).not_to have_received(:course_create_email)
          end
        end

        context "with a user with notifications enabled" do
          let(:user_notification_one) do
            create(
              :user_notification,
              user_id: user_one.id,
              provider_code: accrediting_provider.provider_code,
              course_create: true,
            )
          end

          let(:user_notification_two) do
            create(
              :user_notification,
              user_id: user_one.id,
              provider_code: accrediting_provider.provider_code,
              course_create: false,
            )
          end
          before do
            user_notification_one
            user_notification_two
            subject.call(course: course)
          end

          it "sends the notification to the correct user" do
            expect(mailer_spy).to have_received(:course_create_email) do |course, user|
              expect(course).to eq(course)
              expect(user).to eq(user_one)
            end
          end

          it "delivers the email" do
            expect(mail_spy).to have_received(:deliver_now)
          end

          context "when the course does not appear on find" do
            let(:site_status) { create(:site_status, :unpublished) }

            it "does not send a notification" do
              expect(mailer_spy).not_to have_received(:course_create_email)
            end
          end
        end

        context "with multiple users with notifications enabled" do
          let(:user_notification_one) do
            create(
              :user_notification,
              user_id: user_one.id,
              provider_code: accrediting_provider.provider_code,
              course_create: true,
            )
          end

          let(:user_notification_two) do
            create(
              :user_notification,
              user_id: user_one.id,
              provider_code: accrediting_provider.provider_code,
              course_create: true,
            )
          end
          before do
            user_notification_one
            user_notification_two
          end

          it "sends an email for each user" do
            subject.call(course: course)

            expect(mailer_spy).to have_received(:course_create_email).twice
          end
        end

        context "with multiple users for different providers" do
          let(:provider_two) { create(:provider) }
          let(:user_notification_one) do
            create(
              :user_notification,
              user_id: user_one.id,
              provider_code: accrediting_provider.provider_code,
              course_create: true,
            )
          end

          let(:user_notification_two) do
            create(
              :user_notification,
              user_id: user_one.id,
              provider_code: accrediting_provider.provider_code,
              course_create: false,
            )
          end
          before do
            user_notification_one
            user_notification_two
          end

          it "only sends the email for the courses accrediting provider" do
            subject.call(course: course)

            expect(mailer_spy).to have_received(:course_create_email) do |_course, user|
              expect(user).to eq(user_one)
            end
          end
        end
      end
    end
  end
end
