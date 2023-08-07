# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserAssociationsService::Create, { can_edit_current_and_next_cycles: false } do
  let!(:user) { create(:user) }
  let(:accredited_provider) { create(:provider, :accredited_provider, users: [user]) }
  let!(:new_accredited_provider) { create(:provider, :accredited_provider, provider_code: 'AAA') }
  let!(:next_cycle_new_accredited_provider) { create(:provider, :accredited_provider, :next_recruitment_cycle, users: [user], provider_code: 'AAA') }

  describe '#call' do
    context 'when adding to a single organisation' do
      context 'when two recruitment cycles are active', { can_edit_current_and_next_cycles: true } do
        context 'when the user is added in the current cycle' do
          subject do
            described_class.call(
              provider: new_accredited_provider,
              user:
            )
          end

          it 'creates user_permissions association in both cycles' do
            subject
            expect(new_accredited_provider.users).to eq([user])
            expect(next_cycle_new_accredited_provider.users).to eq([user])
            expect(user.providers).to include(accredited_provider, new_accredited_provider, next_cycle_new_accredited_provider)
          end
        end

        context 'when the user is added in the next cycle' do
          subject do
            described_class.call(
              provider: next_cycle_new_accredited_provider,
              user:
            )
          end

          it 'creates user_permissions association in both cycles' do
            subject
            expect(next_cycle_new_accredited_provider.users).to eq([user])
            expect(new_accredited_provider.users).to eq([user])
            expect(user.providers).to include(accredited_provider, new_accredited_provider, next_cycle_new_accredited_provider)
          end
        end

        context 'when provider does not exist in the next cycle' do
          subject do
            described_class.call(
              provider: current_cycle_provider,
              user:
            )
          end

          let!(:current_cycle_provider) { create(:provider, :accredited_provider, users: [user]) }

          it 'adds user to provider in current cycle without error' do
            expect { subject }.not_to raise_error
            expect(current_cycle_provider.users).to eq([user])
          end
        end
      end

      context 'when only one recruitment cycle is active' do
        subject do
          described_class.call(
            provider: new_accredited_provider,
            user:
          )
        end

        let(:action_mailer) { double }

        before do
          allow(NewUserAddedBySupportTeamMailer).to receive(:user_added_to_provider_email).and_return(action_mailer)
          allow(action_mailer).to receive(:deliver_later)
        end

        it 'sends the email to the user' do
          subject
          expect(NewUserAddedBySupportTeamMailer).to have_received(:user_added_to_provider_email).with(hash_including(recipient: user))
          expect(action_mailer).to have_received(:deliver_later)
        end

        context 'when user have saved notification preferences' do
          let(:user_notification) do
            create(
              :user_notification,
              user:,
              provider: accredited_provider,
              course_publish: true,
              course_update: true
            )
          end

          let(:new_user_notification) do
            create(
              :user_notification,
              user:,
              provider: new_accredited_provider,
              course_publish: true,
              course_update: true
            )
          end

          before do
            user_notification
          end

          it 'creates user_permissions association' do
            subject

            expect(new_accredited_provider.users).to eq([user])
            expect(user.providers).to include(accredited_provider, new_accredited_provider)
          end

          it 'creates user_notifications association with the previous enabled value' do
            subject

            expect(UserNotification.where(user_id: user.id).count).to eq(2)
            expect(UserNotification.where(user_id: user.id)).to include(new_user_notification)
          end
        end

        context 'when user has never set notification preferences' do
          it 'creates user_permissions association' do
            subject

            expect(new_accredited_provider.users).to eq([user])
            expect(user.providers).to include(accredited_provider, new_accredited_provider)
          end

          it "doesn't create user_notifications association" do
            subject

            expect(UserNotification.where(user_id: user.id).count).to eq(0)
          end
        end
      end
    end

    context 'when adding to all providers' do
      subject do
        described_class.call(
          user:,
          all_providers: true
        )
      end

      let(:accredited_provider) { create(:provider, :accredited_provider) }
      let!(:provider1) { create(:provider, :accredited_provider) }

      context 'when user have saved notification preferences' do
        let(:user_notification) do
          create(
            :user_notification,
            user:,
            provider: accredited_provider,
            course_publish: true,
            course_update: true
          )
        end

        before do
          user_notification
        end

        it 'creates user_permissions association' do
          subject

          expect(user.providers).to match_array(Provider.all)
        end

        it "creates user_notifications association for all user's accredited bodies" do
          subject

          expect(UserNotification.where(user_id: user.id).count).to eq(3)
        end
      end

      context 'when user has never set notification preferences' do
        it 'creates user_permissions association' do
          subject

          expect(user.providers).to match_array(Provider.all)
        end

        it "doesn't create user_notifications association" do
          subject

          expect(UserNotification.where(user_id: user.id).count).to eq(0)
        end
      end
    end
  end
end
