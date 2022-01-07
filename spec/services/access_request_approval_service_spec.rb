require "rails_helper"

describe AccessRequestApprovalService do
  describe ".call" do
    let!(:access_request) { create(:access_request) }

    subject(:call_service!) { described_class.call(access_request) }

    context "for a new user" do
      let(:target_user) { User.find_by(email: access_request.email_address) }

      it "creates the new user" do
        expect { call_service! }.to change { User.count }.by(1)
      end

      it "sets the email address" do
        call_service!
        expect(User.where(email: access_request.email_address)).to exist
      end

      it "sets the first_name" do
        call_service!
        expect(target_user.first_name).to eq(access_request.first_name)
      end

      it "sets the last_name" do
        call_service!
        expect(target_user.last_name).to eq(access_request.last_name)
      end

      it "sets the invite date" do
        call_service!
        expect(target_user.invite_date_utc).to be_within(1.second).of Time.now.utc
      end

      it "is marked completed" do
        expect { call_service! }.to change { access_request.status }
          .from("requested")
          .to("completed")
      end

      context "with capitals in the email address" do
        let!(:access_request) { create(:access_request, email_address: "Abc@de.com") }

        it "creates the target user with a lowercase email address" do
          call_service!

          expect(User.where(email: "abc@de.com")).to exist
          expect(User.where(email: "Abc@de.com")).not_to exist
        end
      end
    end

    context "for an existing user" do
      let!(:target_user) { create(:user, email: access_request.email_address) }

      it "does not create a new user" do
        expect { call_service! }.not_to(change { User.count })
      end

      it "sets the target user's providers to the requesting user's providers" do
        expect { call_service! }.to change { target_user.reload.providers }
          .to(access_request.requester.providers)
      end

      context "with existing providers" do
        let(:target_user) do
          create(:user, :with_provider, email: access_request.email_address)
        end
        let!(:access_request) { create(:access_request) }
        let!(:old_provider) { target_user.providers.first }
        let(:requester) { access_request.requester }

        it "keeps the existing provider and gain access to new ones" do
          call_service!
          target_user.providers.reload

          expect(target_user.providers).to(
            include(requester.providers.first),
          )
          expect(target_user.providers).to include(old_provider)
        end
      end

      context "with matching existing providers" do
        let!(:access_request) { create(:access_request) }
        let!(:target_user) do
          create(
            :user,
            email: access_request.email_address,
            providers: access_request.requester.providers,
          )
        end

        it "does not change the orgnisations of the target user" do
          expect { call_service! }.not_to(change { target_user.providers.reload })
        end

        it "does not duplicate the records" do
          call_service!
          target_user.providers.reload

          expect(target_user.providers).to(
            match_array(access_request.requester.providers),
          )
        end
      end

      context "when the requested email is different case to the existing user" do
        let!(:target_user) do
          create(:user, email: "ab@c.com", providers: [])
        end
        let!(:access_request) { create(:access_request, email_address: "Ab@c.com") }

        it "does not duplicate the user" do
          call_service!
          target_user.providers.reload

          expect(User.where(email: "Abc@de.com")).not_to exist
          expect(target_user.providers).to(
            match_array(access_request.requester.providers),
          )
        end
      end
    end

    context "writing data concurrently" do
      let(:requester_provider_count) { access_request.requester.providers.count }

      it "successfully writes to user_permission" do
        expect { call_service! }.to change { UserPermission.count }.by(requester_provider_count)
      end
    end
  end
end
