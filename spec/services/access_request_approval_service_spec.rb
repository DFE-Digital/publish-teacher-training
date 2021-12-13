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

      it "gives the user access to the requestor's orgs" do
        call_service!
        expect(target_user.organisations).to(
          match_array(access_request.requester.organisations),
        )
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

      it "sets the target user's organisations to the requesting user's organisations" do
        expect { call_service! }.to change { target_user.reload.organisations }
          .to(access_request.requester.organisations)
      end

      context "with existing organisations" do
        let(:target_user) do
          create(:user, :with_organisation, email: access_request.email_address)
        end
        let!(:access_request)   { create(:access_request) }
        let!(:old_organisation) { target_user.organisations.first }
        let(:requester) { access_request.requester }

        it "keeps the existing organisation and gain access to new ones" do
          call_service!
          target_user.organisations.reload

          expect(target_user.organisations).to(
            include(requester.organisations.first),
          )
          expect(target_user.organisations).to include(old_organisation)
        end
      end

      context "with matching existing organisations" do
        let!(:access_request) { create(:access_request) }
        let!(:target_user) do
          create(
            :user,
            email: access_request.email_address,
            organisations: access_request.requester.organisations,
          )
        end

        it "does not change the orgnisations of the target user" do
          expect { call_service! }.not_to(change { target_user.organisations.reload })
        end

        it "does not duplicate the records" do
          call_service!
          target_user.organisations.reload

          expect(target_user.organisations).to(
            match_array(access_request.requester.organisations),
          )
        end
      end

      context "when the requested email is different case to the existing user" do
        let!(:target_user) do
          create(:user, email: "ab@c.com", organisations: [])
        end
        let!(:access_request) { create(:access_request, email_address: "Ab@c.com") }

        it "does not duplicate the user" do
          call_service!
          target_user.organisations.reload

          expect(User.where(email: "Abc@de.com")).not_to exist
          expect(target_user.organisations).to(
            match_array(access_request.requester.organisations),
          )
        end
      end
    end

    context "writing data concurrently" do
      let(:organisation_provider_count) { access_request.requester.organisations.flat_map(&:providers).count }

      it "writes to both user_permission and organisation_user" do
        expect { call_service! }.to change { OrganisationUser.count }.by(1).and \
          change { UserPermission.count }.by(organisation_provider_count)
      end
    end
  end
end
