require 'mcb_helper'

describe 'mcb courses create' do
  def create_new_course_on(provider_code)
    cmd.run([provider_code])
  end

  let(:lib_dir) { Rails.root.join('lib') }
  let(:cmd) do
    Cri::Command.load_file("#{lib_dir}/mcb/commands/courses/create.rb")
  end
  let(:provider_code) { 'X12' }
  let(:email) { 'user@education.gov.uk' }
  let!(:provider) { create(:provider, provider_code: provider_code) }

  before do
    allow(MCB).to receive(:config).and_return(email: email)
  end

  context 'for an authorised user' do
    let!(:requester) { create(:user, email: email, organisations: provider.organisations) }

    it 'launches the courses editor' do
      allow(MCB::CoursesEditor).to receive(:new).and_return(instance_double(MCB::CoursesEditor, new_course_wizard: nil))

      create_new_course_on(provider_code)

      expect(MCB::CoursesEditor).to have_received(:new)
    end

    describe 'trying to edit a course on a nonexistent provider' do
      it 'raises an error' do
        expect { create_new_course_on("ABC") }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find Provider/)
      end
    end

    context 'when the same provider exists across multiple recruitment cycles' do
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

      it 'picks the correct provider' do
        create_new_course_on(provider_code)

        expect(MCB::CoursesEditor).to have_received(:new)
      end

      it 'ignores providers associated with the next cycle' do
        provider.destroy

        expect { create_new_course_on(provider_code) }.
          to raise_error(ActiveRecord::RecordNotFound, /Couldn't find Provider/)
        expect(MCB::CoursesEditor).to_not have_received(:new)
      end
    end
  end

  context 'when a non-existent user tries to edit a course' do
    let!(:requester) { create(:user, email: 'someother@email.com') }

    it 'raises an error' do
      expect { create_new_course_on(provider_code) }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find User/)
    end
  end
end
