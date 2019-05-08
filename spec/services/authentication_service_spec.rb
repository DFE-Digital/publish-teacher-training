describe AuthenticationService do
  describe '.call' do
    let(:user) { create(:user) }

    subject { described_class.call(encode_token(payload)) }

    def encode_token(payload)
      JWT.encode(
        payload,
        Settings.authentication.secret,
        Settings.authentication.algorithm
      )
    end

    context 'with a valid DfE-SignIn ID and email' do
      let(:payload) do
        {
          email:           user.email,
          sign_in_user_id: user.sign_in_user_id
        }
      end

      it { should eq user }
    end

    context 'with a valid DfE-SignIn ID but invalid email' do
      let(:email) { Faker::Internet.email }
      let(:payload) do
        {
          email:           email,
          sign_in_user_id: user.sign_in_user_id
        }
      end

      it { should eq user }
      it "update's the user's email" do
        expect { subject }.to(change { user.reload.email }.to(email))
      end

      context 'when the email is already in use' do
        let!(:existing_user) { create(:user, email: email) }

        it { should eq user }
        it "does not update the user's email" do
          expect { subject }.not_to(change { user.reload.email })
        end

        it 'generates an exception which is captured by Sentry' do
          expect(Raven).to receive(:capture).with(
            instance_of(AuthenticationService::DuplicateUserError)
          )

          subject
        end
      end
    end

    context 'with a valid email but an invalid DfE-SignIn ID' do
      let(:payload) do
        {
          email:           user.email,
          sign_in_user_id: SecureRandom.uuid
        }
      end

      it { should eq user }
    end

    context 'with an email that has different case from the database' do
      let(:payload) { { email: user.email.upcase } }

      before do
        user.update(email: user.email.capitalize)
      end

      it { should eq user }
    end

    context 'when the email is an empty string' do
      before do
        user.update_attribute(:email, '')
      end

      let(:payload) do
        {
          email:           '',
          sign_in_user_id: SecureRandom.uuid
        }
      end

      it 'does not authenticate the user based on an empty string match' do
        expect(subject).not_to eq user
      end
    end

    context 'when the sign_in_user_id is nil' do
      let!(:user) { create(:user, sign_in_user_id: nil) }
      let(:payload) do
        {
          email:           Faker::Internet.email,
          sign_in_user_id: nil
        }
      end

      it 'does not authenticate the user based on a nil match' do
        expect(subject).not_to eq user
      end
    end
  end
end
