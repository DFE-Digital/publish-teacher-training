require "rails_helper"

describe AccessRequestApprovalService do
  describe ".call" do
    let!(:access_request) { create(:access_request) }

    subject { described_class.call(access_request) }

    context "for a new user" do
      let(:target_user) { User.find_by(email: access_request.email_address) }

      it "should create the new user" do
        expect { subject }.to change { User.count }.by(1)
      end

      it "should set the email address" do
        subject
        expect(User.where(email: access_request.email_address)).to exist
      end

      it "should set the first_name" do
        subject
        expect(target_user.first_name).to eq(access_request.first_name)
      end

      it "should set the last_name" do
        subject
        expect(target_user.last_name).to eq(access_request.last_name)
      end

      it "should set the invite date" do
        subject
        expect(target_user.invite_date_utc).to be_within(1.second).of Time.now.utc
      end

      it "should set the state" do
        subject
        expect(target_user.state).to eq("new")
      end

      it "should give the user access to the requestor's orgs" do
        subject
        expect(target_user.organisations).to(
          match_array(access_request.requester.organisations),
        )
      end

      it "should be marked completed" do
        expect { subject }.to change { access_request.status }
          .from("requested")
          .to("completed")
      end

      context "with capitals in the email address" do
        let!(:access_request) { create(:access_request, email_address: "Abc@de.com") }

        it "creates the target user with a lowercase email address" do
          subject

          expect(User.where(email: "abc@de.com")).to exist
          expect(User.where(email: "Abc@de.com")).to_not exist
        end
      end
    end

    context "for an existing user" do
      let!(:target_user) { create(:user, email: access_request.email_address) }

      it "does not create a new user" do
        expect { subject }.not_to(change { User.count })
      end

      it "sets the target user's organisations to the requesting user's organisations" do
        expect { subject }.to change { target_user.reload.organisations }
          .to(access_request.requester.organisations)
      end

      context "with existing organisations" do
        let(:target_user) do
          create(:user, :with_organisation, email: access_request.email_address)
        end
        let!(:access_request)   { create(:access_request) }
        let!(:old_organisation) { target_user.organisations.first }
        let(:requester) { access_request.requester }

        it "should keep the existing organisation and gain access to new ones" do
          subject
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
          expect { subject }.not_to(change { target_user.organisations.reload })
        end

        it "shouldn't duplicate the records" do
          subject
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

        it "shouldn't duplicate the user" do
          subject
          target_user.organisations.reload

          expect(User.where(email: "Abc@de.com")).to_not exist
          expect(target_user.organisations).to(
            match_array(access_request.requester.organisations),
          )
        end
      end
    end
  end
end
