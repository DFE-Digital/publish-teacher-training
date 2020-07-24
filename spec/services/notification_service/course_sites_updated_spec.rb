require "rails_helper"

module NotificationService
  describe CourseSitesUpdated do
    describe "#call" do
      let(:accredited_body) { create(:provider, :accredited_body) }
      let(:other_accredited_body) { create(:provider, :accredited_body) }
      let(:course) { create(:course, accrediting_provider: accredited_body) }
      let(:previous_site_names) { ["location 1", "location 2"] }
      let(:updated_site_names) { ["location 3", "location 4"] }

      let(:subscribed_user) { create(:user) }
      let(:non_subscribed_user) { create(:user) }
      let(:user_subscribed_to_other_provider) { create(:user) }

      let(:subscribed_notification) do
        create(
          :user_notification,
          user: subscribed_user,
          course_update: true,
          provider_code: accredited_body.provider_code,
        )
      end

      let(:non_subscribed_notification) do
        create(
          :user_notification,
          user: non_subscribed_user,
          course_update: false,
          provider_code: accredited_body.provider_code,
        )
      end

      let(:other_provider_notification) do
        create(
          :user_notification,
          user: user_subscribed_to_other_provider,
          course_update: true,
          provider_code: other_accredited_body.provider_code,
        )
      end
      let(:self_accredited) { false }
      let(:findable) { true }

      def setup_notifications
        allow(CourseSitesUpdateEmailMailer).to receive(:course_sites_update_email).and_return(double(deliver_later: true))
        subscribed_notification
        non_subscribed_notification
        other_provider_notification
        allow(course).to receive(:self_accredited?).and_return(self_accredited)
        allow(course).to receive(:findable?).and_return(findable)
      end

      context "with a course that is in the current cycle" do
        before { setup_notifications }

        it "sends notifications" do
          expect(CourseSitesUpdateEmailMailer).to receive(:course_sites_update_email)
          expect(course.recruitment_cycle).to eql(RecruitmentCycle.current)
          described_class.call(
            course: course,
            previous_site_names: previous_site_names,
            updated_site_names: updated_site_names,
          )
        end
      end

      context "with a course that is not in the current cycle" do
        let(:provider) { create(:provider, :next_recruitment_cycle) }
        let(:course) { create(:course, accredited_body_code: accredited_body.provider_code, provider: provider) }

        before { setup_notifications }

        it "does not notifications" do
          expect(CourseSitesUpdateEmailMailer).to_not receive(:course_sites_update_email)
          expect(course.recruitment_cycle).to_not eql(RecruitmentCycle.current)
          described_class.call(
            course: course,
            previous_site_names: previous_site_names,
            updated_site_names: updated_site_names,
          )
        end
      end

      context "non self-accredited course" do
        before { setup_notifications }

        context "that is findable?" do
          it "mails subscribed users" do
            expect(CourseSitesUpdateEmailMailer)
              .to receive(:course_sites_update_email)
                    .with(
                      course: course,
                      recipient: subscribed_user,
                      previous_site_names: previous_site_names,
                      updated_site_names: updated_site_names,
                    ).and_return(mailer = double)
            expect(mailer).to receive(:deliver_later).with(queue: "mailer")
            described_class.call(
              course: course,
              previous_site_names: previous_site_names,
              updated_site_names: updated_site_names,
            )
          end

          it "does not email non subscribed users" do
            expect(CourseSitesUpdateEmailMailer).not_to receive(:course_sites_update_email)
                                                          .with(course, non_subscribed_user)
            expect(CourseSitesUpdateEmailMailer).not_to receive(:course_sites_update_email)
                                                          .with(course, user_subscribed_to_other_provider)
            described_class.call(
              course: course,
              previous_site_names: previous_site_names,
              updated_site_names: updated_site_names,
            )
          end
        end

        context "that is not findable?" do
          let(:findable) { false }

          it "does not mail subscribed users" do
            expect(CourseSitesUpdateEmailMailer)
              .not_to receive(:course_sites_update_email)
            described_class.call(
              course: course,
              previous_site_names: previous_site_names,
              updated_site_names: updated_site_names,
            )
          end
        end
      end

      context "self accredited course" do
        let(:self_accredited) { true }

        before { setup_notifications }

        it "does not mail subscribed users" do
          expect(CourseSitesUpdateEmailMailer)
            .not_to receive(:course_sites_update_email)
          described_class.call(
            course: course,
            previous_site_names: previous_site_names,
            updated_site_names: updated_site_names,
          )
        end
      end
    end
  end
end
