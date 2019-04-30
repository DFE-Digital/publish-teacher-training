describe AccessRequestApprovalService do
  describe '.call' do
    let!(:access_request) { create(:access_request) }

    subject { described_class.call(access_request) }

    context 'for a new user' do
      let(:new_user) { User.find_by(email: access_request.email_address) }

      it 'should create the new user'do
        expect { subject }.to change { User.count }.by(1)
      end

      it 'should set the email address'do
        subject
        expect(User.where(email: access_request.email_address)).to exist
      end

      it 'should set the first_name'do
        subject
        expect(new_user.first_name).to eq(access_request.first_name)
      end

      it 'should set the last_name'do
        subject
        expect(new_user.last_name).to eq(access_request.last_name)
      end

      it 'should set the invite date'do
        subject
        expect(new_user.invite_date_utc).to be_within(1.second).of Time.now.utc
      end

      it "should give the user access to the requestor's orgs" do
        subject
        expect(new_user.organisations).to(
          match_array(access_request.user.organisations)
        )
      end

      it 'should be marked completed' do
        expect { subject }.to change { access_request.status }
          .from('requested')
          .to('completed')
      end
    end

    context 'for an existing user' do
      let!(:user) { create(:user, email: access_request.email_address) }

      it 'does not create a new user' do
        expect { subject }.not_to(change { User.count })
      end

      context 'with no organisations' do
      end

      context 'with unrelated existing organisations' do
        xit "shouldn't lose them"
      end

      context 'with matching existing organisations' do
        xit "shouldn't duplicate the records"
      end
    end
  end
end
