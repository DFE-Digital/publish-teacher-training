require 'mcb_helper'

fdescribe 'mcb providers create' do
  let(:providers_create) { MCBCommand.new('providers', 'create') }

  let(:email) { 'user@education.gov.uk' }
  let(:organisation) { create(:organisation) }
  before do
    allow(MCB).to receive(:config).and_return(email: email)
  end

  context 'for an authorised user' do
    let!(:requester) { create(:user, email: email, organisations: [organisation]) }

    it 'launches the provider editor' do
      allow(MCB::ProviderEditor).to receive(:new).and_return(instance_double(MCB::ProviderEditor, new_provider_wizard: nil))

      providers_create.execute

      expect(MCB::ProviderEditor).to have_received(:new)
    end

    xcontext 'when the same provider exists across multiple recruitment cycles' do
      let!(:next_recruitment_cycle) { find_or_create(:recruitment_cycle, :next) }
      let!(:provider_in_the_next_recruitment_cycle) {
        create(:provider,
               provider_code: provider_code,
               recruitment_cycle: next_recruitment_cycle,
               organisations: provider.organisations)
      }

      before do
        allow(MCB::CoursesEditor).to receive(:new)
          .and_return(instance_double(MCB::CoursesEditor, new_course_wizard: nil))
      end

      it 'picks the provider in the current cycle by default' do
        create_new_course_on(provider_code)

        expect(MCB::CoursesEditor)
          .to have_received(:new)
          .with(hash_including(provider: provider, requester: requester))
      end

      it 'picks the provider in the specified recruitment cycle when appropriate' do
        create_new_course_on(provider_code, in_recruitment_year: next_recruitment_cycle.year)

        expect(MCB::CoursesEditor)
          .to have_received(:new)
          .with(hash_including(provider: provider_in_the_next_recruitment_cycle, requester: requester))
      end
    end
  end
end
