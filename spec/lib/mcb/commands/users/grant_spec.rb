require 'mcb_helper'

describe 'mcb users grant' do
  def grant(id_or_email_or_sign_in_id, provider_code, commands)
    stderr = ""
    output = with_stubbed_stdout(stdin: commands, stderr: stderr) do
      cmd.run([id_or_email_or_sign_in_id, provider_code])
    end
    [output, stderr]
  end

  let(:lib_dir) { "#{Rails.root}/lib" }
  let(:cmd) do
    Cri::Command.load_file(
      "#{lib_dir}/mcb/commands/users/grant.rb"
    )
  end
  let(:organisation) { create(:organisation) }
  let(:provider) { create(:provider, organisations: [organisation]) }

  let(:output) do
    combined_input = input_commands.map { |c| "#{c}\n" }.join
    grant(id_or_email_or_sign_in_id, provider.provider_code, combined_input).first
  end

  context 'when the user exists and already has access to the provider' do
    let(:id_or_email_or_sign_in_id) { user.email }
    let(:input_commands) { [] }
    let(:user) { create(:user, organisations: [organisation]) }

    it 'informs the support agent that it is not going to do anything' do
      expect(output).to include("#{user} already belongs to #{organisation.name}")
    end
  end

  context 'when the user does not exist' do
    let(:id_or_email_or_sign_in_id) { 'jsmith@acme.org' }
    let(:input_commands) { %w[Jane Smith y y] }

    before do
      output
    end

    it 'creates the user' do
      expect(User.find_by(first_name: 'Jane', last_name: 'Smith', email: 'jsmith@acme.org')).to be_present
    end

    it 'grants organisation membership to that user' do
      user = User.find_by!(first_name: 'Jane', last_name: 'Smith', email: 'jsmith@acme.org')
      expect(user.organisations).to eq([organisation])
    end

    it 'confirms user creation and organisation membership' do
      expect(output).to include("jsmith@acme.org appears to be a new user")
      expect(output).to include("You're about to give Jane Smith <jsmith@acme.org> access to organisation #{organisation.name}.")
    end
  end

  context 'when the user details are invalid' do
    let(:id_or_email_or_sign_in_id) { 'jsmith' }
    let(:input_commands) { %w[Jane Smith] }

    before do
      output
    end

    it 'does not create the user' do
      expect(User.count).to eq(0)
    end

    it 'displays the validation errors' do
      expect(output).to include("Specify an email address if you wish to create a user")
    end
  end

  context 'when the user exists but is not a member of the org' do
    let(:user) { create(:user, organisations: []) }
    let(:id_or_email_or_sign_in_id) { user.email }
    let(:input_commands) { %w[y] }

    before do
      output
    end

    it 'grants organisation membership to that user' do
      expect(user.reload.organisations).to eq([organisation])
    end

    it 'confirms user creation and organisation membership' do
      expect(output).to include("You're about to give #{user} access to organisation #{organisation.name}.")
    end
  end
end
