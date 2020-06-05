require "rails_helper"

RSpec.describe UserAssociationsService::Create do
  let(:user) { create :user }

  describe "#call" do
    context "when adding to a single organsation" do
      let(:accredited_body) { create(:provider, :accredited_body) }
      let(:organisation) { create(:organisation, users: [user], providers: [accredited_body]) }

      let(:new_accredited_body) { create(:provider, :accredited_body) }
      let(:new_organisation) { create(:organisation, providers: [new_accredited_body]) }

      subject do
        described_class.call(
          organisation: new_organisation,
          user: user,
        )
      end

      context "when user have saved notification preferences" do
        let(:user_notification) do
          create(
            :user_notification,
            user: user,
            provider: accredited_body,
            course_publish: true,
            course_update: true,
          )
        end

        let(:new_user_notification) do
          create(
            :user_notification,
            user: user,
            provider: new_accredited_body,
            course_publish: true,
            course_update: true,
          )
        end

        before do
          organisation
          user_notification
        end

        it "creates organisation_users association" do
          subject

          expect(new_organisation.users).to eq([user])
          expect(user.organisations).to include(organisation, new_organisation)
        end

        it "creates user_notifications association with the previous enabled value" do
          subject

          expect(UserNotification.where(user_id: user.id).count).to eq(2)
          expect(UserNotification.where(user_id: user.id)).to include(new_user_notification)
        end
      end

      context "when user has never set notification preferences" do
        before do
          organisation
        end

        it "creates organisation_users association" do
          subject

          expect(new_organisation.users).to eq([user])
          expect(user.organisations).to include(organisation, new_organisation)
        end

        it "doesn't create user_notifications association" do
          subject

          expect(UserNotification.where(user_id: user.id).count).to eq(0)
        end
      end
    end

    context "when adding to all organsations" do
      subject do
        described_class.call(
          user: user,
          all_organisations: true,
        )
      end

      let(:accredited_body) { create(:provider, :accredited_body) }
      let(:organisation1) do
        create(:organisation,
               providers: [accredited_body])
      end

      let(:organisation2) do
        create(:organisation,
               providers: [create(:provider, :accredited_body)])
      end

      before do
        organisation1
        organisation2
      end

      context "when user have saved notification preferences" do
        let(:user_notification) do
          create(
            :user_notification,
            user: user,
            provider: accredited_body,
            course_publish: true,
            course_update: true,
          )
        end

        before do
          user_notification
        end

        it "creates organisation_users association" do
          subject

          expect(user.organisations).to match_array(Organisation.all)
        end

        it "creates user_notifications association for all user's accredited bodies" do
          subject

          expect(UserNotification.where(user_id: user.id).count).to eq(2)
        end
      end

      context "when user has never set notification preferences" do
        it "creates organisation_users association" do
          subject

          expect(user.organisations).to match_array(Organisation.all)
        end

        it "doesn't create user_notifications association" do
          subject

          expect(UserNotification.where(user_id: user.id).count).to eq(0)
        end
      end
    end
  end
end
