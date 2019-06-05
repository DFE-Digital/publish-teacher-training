require 'mcb_helper'

describe 'mcb courses edit' do
  def edit(provider_code, course_codes, *input_cmds)
    stderr = nil
    output = with_stubbed_stdout(stdin: input_cmds.join("\n"), stderr: stderr) do
      cmd.run([provider_code] + course_codes)
    end
    [output, stderr]
  end

  let(:lib_dir) { "#{Rails.root}/lib" }
  let(:cmd) do
    Cri::Command.load_file("#{lib_dir}/mcb/commands/courses/edit.rb")
  end
  let(:provider_code) { 'X12' }
  let(:course_code) { '3FC4' }
  let(:email) { 'user@education.gov.uk' }
  let(:provider) { create(:provider, provider_code: provider_code) }
  let!(:course) {
    create(:course,
           provider: provider,
           course_code: course_code,
           name: 'Original name')
  }

  before do
    allow(MCB).to receive(:config).and_return(email: email)
  end

  context 'for an authorised user' do
    let!(:requester) { create(:user, email: email, organisations: provider.organisations) }

    describe 'edits the course name for a single course' do
      it 'updates the course' do
        expect { edit(provider_code, [course_code], "Mathematics") }.to change { course.reload.name }.
          from("Original name").to("Mathematics")
      end
    end

    describe 'trying to edit a course on a nonexistent provider' do
      it 'raises an error' do
        expect { edit("ABC", [course_code]) }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find Provider/)
      end
    end

    describe 'not specifying any course codes' do
      let!(:another_course) {
        create(:course,
               provider: provider,
               course_code: "A123",
               name: 'Another name')
      }

      it 'edits all the courses on the provider' do
        expect { edit(provider_code, [], "Mathematics") }.
          to change { provider.reload.courses.order(:name).pluck(:name) }.
          from(["Another name", "Original name"]).to(%w[Mathematics Mathematics])
      end
    end
  end

  context 'when a non-existent user tries to edit a course' do
    let!(:requester) { create(:user, email: 'someother@email.com') }

    it 'raises an error' do
      expect { edit(provider_code, [course_code]) }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find User/)
    end
  end
end
