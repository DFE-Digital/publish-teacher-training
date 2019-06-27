require 'mcb_helper'

describe 'mcb users revoke' do
  let(:lib_dir) { Rails.root.join('lib') }
  let(:cmd) do
    Cri::Command.load_file(
      "#{lib_dir}/mcb/commands/users/revoke.rb"
    )
  end
  let(:organisation) { create(:organisation) }
  let(:provider) { create(:provider, organisations: [organisation]) }
  let(:other_organisation) { create(:organisation) }
  let(:other_provider) { create(:provider, organisations: [other_organisation]) }
  let(:other_user) { create(:user, organisations: [organisation, other_organisation]) }

  describe 'one provider' do
    def revoke(id_or_email_or_sign_in_id, provider_code, commands)
      stderr = ""
      output = with_stubbed_stdout(stdin: commands, stderr: stderr) do
        cmd.run([id_or_email_or_sign_in_id, '-p', provider_code])
      end
      [output, stderr]
    end

    let(:output) do
      combined_input = input_commands.map { |c| "#{c}\n" }.join
      revoke(id_or_email_or_sign_in_id, provider.provider_code, combined_input).first
    end

    context 'when the user exists and has access to the provider' do
      let(:id_or_email_or_sign_in_id) { user.email }
      let(:input_commands) { %w[y] }
      let(:user) { create(:user, organisations: [organisation, other_organisation]) }

      before do
        output
      end

      it 'revokes organisation membership to that user' do
        user = User.find_by!(email: id_or_email_or_sign_in_id)
        expect(user.reload.organisations).to eq([other_organisation])
        expect(other_user.organisations).to eq([organisation, other_organisation])
      end

      it 'confirms removing organisation membership' do
        expect(output).to include("You're revoking access for #{user.email}")
      end
    end

    context 'when the user does not exist' do
      let(:id_or_email_or_sign_in_id) { 'jsmith@acme.org' }
      let(:input_commands) { %w[Jane Smith y y] }

      before do
        output
      end

      it 'informs the support agent that it is not going to do anything' do
        expect(output).to include("#{id_or_email_or_sign_in_id} does not exist")
      end
    end

    context 'when the user exists but is not a member of the org' do
      let(:other_organisation) { create(:organisation) }
      let(:other_provider) { create(:provider, organisations: [other_organisation]) }
      let(:user) { create(:user, organisations: [other_organisation]) }
      let(:id_or_email_or_sign_in_id) { user.email }
      let(:input_commands) { %w[y] }

      before do
        output
      end

      it "leaves membership alone" do
        expect(user.reload.organisations).to eq([other_organisation])
      end

      it 'informs the support agent that it is not going to do anything' do
        expect(output).to include("#{id_or_email_or_sign_in_id} already has no access to #{provider.provider_name}")
      end
    end

    describe 'all providers' do
      def revoke_all(id_or_email_or_sign_in_id, commands)
        stderr = ""
        output = with_stubbed_stdout(stdin: commands, stderr: stderr) do
          cmd.run([id_or_email_or_sign_in_id])
        end
        [output, stderr]
      end

      let(:output) do
        combined_input = input_commands.map { |c| "#{c}\n" }.join
        revoke_all(id_or_email_or_sign_in_id, combined_input).first
      end

      context 'when the user exists and has access to the provider' do
        let(:id_or_email_or_sign_in_id) { user.email }
        let(:input_commands) { %w[y] }
        let(:user) { create(:user, organisations: [organisation, other_organisation]) }

        before do
          output
        end

        it 'revokes organisation membership to that user' do
          user = User.find_by!(email: id_or_email_or_sign_in_id)
          expect(user.reload.organisations).to eq([])
          expect(other_user.organisations).to eq([organisation, other_organisation])
        end

        it 'confirms removing organisation membership' do
          expect(output).to include("You're revoking access for #{user.email}")
        end
      end
    end
  end
end
