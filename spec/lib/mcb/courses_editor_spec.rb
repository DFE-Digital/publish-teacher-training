require 'mcb_helper'

describe MCB::CoursesEditor do
  def run_editor(*input_cmds)
    stderr = nil
    output = with_stubbed_stdout(stdin: input_cmds.join("\n"), stderr: stderr) do
      subject.run
    end
    [output, stderr]
  end

  let(:provider_code) { 'X12' }
  let(:course_code) { '3FC4' }
  let(:course_codes) { [course_code] }
  let(:email) { 'user@education.gov.uk' }
  let(:provider) { create(:provider, provider_code: provider_code) }
  let!(:course) {
    create(:course,
           provider: provider,
           course_code: course_code,
           name: 'Original name')
  }
  subject { described_class.new(provider: provider, course_codes: course_codes, requester: requester) }

  context 'when an authorised user' do
    let!(:requester) { create(:user, email: email, organisations: provider.organisations) }

    describe 'runs the editor' do
      it 'updates the course title' do
        expect { run_editor("Mathematics") }.to change { course.reload.name }.
          from("Original name").to("Mathematics")
      end
    end

    describe 'does not specify any course codes' do
      let!(:another_course) {
        create(:course,
               provider: provider,
               course_code: "A123",
               name: 'Another name')
      }
      let(:course_codes) { [] }

      it 'edits all courses on the provider' do
        expect { run_editor("Mathematics") }.
          to change { provider.reload.courses.order(:name).pluck(:name) }.
          from(["Another name", "Original name"]).to(%w[Mathematics Mathematics])
      end
    end

    describe 'tries to edit a non-existent course' do
      let(:course_codes) { [course_code, "ABCD"] }

      it 'raises an error' do
        expect { subject }.to raise_error(ArgumentError, /Couldn't find course ABCD/)
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
