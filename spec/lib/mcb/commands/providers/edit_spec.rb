require 'mcb_helper'

describe 'mcb providers edit' do
  def edit(provider_code, *input_cmds)
    stderr = nil
    output = with_stubbed_stdout(stdin: input_cmds.join("\n"), stderr: stderr) do
      cmd.run([provider_code])
    end
    [output, stderr]
  end

  let(:lib_dir) { Rails.root.join('lib') }
  let(:cmd) do
    Cri::Command.load_file("#{lib_dir}/mcb/commands/providers/edit.rb")
  end
  let(:provider_code) { 'X12' }
  let(:email) { 'user@education.gov.uk' }
  let(:provider) { create(:provider, provider_code: provider_code, provider_name: 'A') }

  before do
    allow(MCB).to receive(:config).and_return(email: email)
  end

  context 'for an authorised user' do
    let!(:requester) { create(:user, email: email, organisations: provider.organisations) }

    describe 'edits the provider name' do
      it 'updates the course' do
        expect { edit(provider_code, "edit provider name", "B", "exit") }
          .to change { provider.reload.provider_name }
          .from("A").to("B")
      end
    end

    describe 'trying to edit a course on a nonexistent provider' do
      it 'raises an error' do
        expect { edit("ABC") }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find Provider/)
      end
    end
  end

  context 'when a non-existent user tries to edit a course' do
    let!(:requester) { create(:user, email: 'someother@email.com') }

    it 'raises an error' do
      expect { edit(provider_code) }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find User/)
    end
  end
end
