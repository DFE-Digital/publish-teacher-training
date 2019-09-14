require 'mcb_helper'

describe 'mcb users grant', :needs_audit_user do
  def grant(id_or_email_or_sign_in_id, provider_code, commands)
    with_stubbed_stdout(stdin: commands) do
      cmd.run([id_or_email_or_sign_in_id, '-p', provider_code])
    end
  end

  let(:lib_dir) { Rails.root.join('lib') }
  let(:cmd) do
    Cri::Command.load_file(
      "#{lib_dir}/mcb/commands/users/grant.rb"
    )
  end
  let(:organisation) { create(:organisation) }
  let(:provider) { create(:provider, organisations: [organisation]) }

  let(:output) do
    combined_input = input_commands.map { |c| "#{c}\n" }.join
    grant(id_or_email_or_sign_in_id, provider.provider_code, combined_input)[:stdout]
  end

  let(:requester) { create(:user) }

  before do
    allow(MCB).to receive(:config).and_return(email: requester.email)
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

    it 'creates the user with the correct audited by' do
      user = User.find_by(first_name: 'Jane', last_name: 'Smith', email: 'jsmith@acme.org')
      expect(user.audits.last.user).to eq(requester)
    end

    it 'grants organisation membership to that user' do
      user = User.find_by!(first_name: 'Jane', last_name: 'Smith', email: 'jsmith@acme.org')
      expect(user.organisations).to eq([organisation])
    end

    it 'audits the User has been added correctly' do
      audit = organisation.associated_audits.last

      expect(audit.user).to eq(requester)
      expect(audit.action).to eq('create')
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

    # Should not be more than one, as we have a Requester User
    it 'does not create the user' do
      expect(User.count).to eq(1)
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

    it 'audits the User has been added correctly' do
      audit = organisation.associated_audits.last

      expect(audit.user).to eq(requester)
      expect(audit.action).to eq('create')
    end
  end
end
