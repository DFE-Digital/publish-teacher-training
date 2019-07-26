require 'mcb_helper'

fdescribe 'mcb providers create' do
  let(:cmd) { MCBCommand.new('providers', 'create') }

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
      allow(MCB::ProviderEditor).to receive(:new).and_return(instance_double(MCB::ProviderEditor, new_provider_wizard: nil))
    end

    it 'starts the new provider creation in the current cycle by default' do
      cmd.execute

      expect(MCB::ProviderEditor).to have_received(:new) do |args|
        expect(args[:provider].recruitment_cycle).to eq(RecruitmentCycle.current_recruitment_cycle)
        expect(args[:provider]).to be_new_record
      end
    end

    context 'when a recruitment cycle is explicitly specified' do
      let(:cmd) { MCBCommand.new('providers', 'create', '-r', next_recruitment_cycle.year) }

      it 'starts the new provider creation in the specified cycle' do
        cmd.execute

        expect(MCB::ProviderEditor).to have_received(:new) do |args|
          expect(args[:provider].recruitment_cycle).to eq(next_recruitment_cycle)
          expect(args[:provider]).to be_new_record
        end
      end
    end
  end
end
