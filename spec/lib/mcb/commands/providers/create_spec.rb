require 'mcb_helper'

describe 'mcb providers create' do
  def execute_cmd(arguments: [], input: [])
    with_stubbed_stdout(stdin: input.join("\n")) do
      $mcb.run(['providers', 'create', *arguments])
    end
  end

  let(:email) { 'user@education.gov.uk' }
  let(:organisation) { create(:organisation) }
  let(:provider_code) { 'X01' }
  let!(:next_recruitment_cycle) { find_or_create(:recruitment_cycle, :next) }
  before do
    allow(MCB).to receive(:config).and_return(email: email)
  end

  context 'for an authorised user' do
    let!(:requester) { create(:user, email: email, organisations: [organisation]) }

    before do
      allow(MCB::Editor::ProviderEditor).to receive(:new).and_return(instance_double(MCB::Editor::ProviderEditor, new_provider_wizard: nil))
    end

    it 'starts the new provider creation in the current cycle by default' do
      execute_cmd

      expect(MCB::Editor::ProviderEditor).to have_received(:new) do |args|
        expect(args[:provider].recruitment_cycle).to eq(RecruitmentCycle.current_recruitment_cycle)
        expect(args[:provider]).to be_new_record
      end
    end

    context 'when a recruitment cycle is explicitly specified' do
      it 'starts the new provider creation in the specified cycle' do
        execute_cmd(arguments: ['-r', next_recruitment_cycle.year])

        expect(MCB::Editor::ProviderEditor).to have_received(:new) do |args|
          expect(args[:provider].recruitment_cycle).to eq(next_recruitment_cycle)
          expect(args[:provider]).to be_new_record
        end
      end
    end
  end
end
