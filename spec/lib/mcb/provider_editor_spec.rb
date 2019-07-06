require 'mcb_helper'

describe MCB::ProviderEditor do
  def run_editor(*input_cmds)
    stderr = nil
    output = with_stubbed_stdout(stdin: input_cmds.join("\n"), stderr: stderr) do
      subject.run
    end
    [output, stderr]
  end

  let(:provider_code) { 'X12' }
  let(:email) { 'user@education.gov.uk' }
  let(:provider) {
    create(:provider,
           provider_code: provider_code,
           provider_name: 'Original name')
  }

  subject { described_class.new(provider: provider, requester: requester) }

  context 'when an authorised user' do
    let!(:requester) { create(:user, email: email, organisations: provider.organisations) }

    describe 'runs the editor' do
      it 'updates the provider name' do
        expect { run_editor("edit provider name", "ACME SCITT", "exit") }
          .to change { provider.reload.provider_name }
          .from("Original name").to("ACME SCITT")
      end

      it 'does nothing upon an immediate exit' do
        expect { run_editor("exit") }.to_not change { provider.reload.provider_name }.
          from("Original name")
      end
    end
  end

  context 'for an unauthorised user' do
    let!(:requester) { create(:user, email: email, organisations: []) }

    it 'raises an error' do
      expect { subject }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
