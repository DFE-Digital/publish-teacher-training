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

      describe "(course editing)" do
        let!(:courses) { create(:course, course_code: 'A01X', name: 'Biology', provider: provider) }
        let!(:course2) { create(:course, course_code: 'A02X', name: 'History', provider: provider) }
        let!(:course3) { create(:course, course_code: 'A03X', name: 'Economics', provider: provider) }

        it 'lists the courses for the given provider' do
          output, = run_editor("edit courses", "continue", "exit")
          expect(output).to include("[ ] Biology (A01X)", "[ ] History (A02X)", "[ ] Economics (A03X)")
        end

        it 'invokes course editing on the selected courses' do
          allow($mcb).to receive(:run)

          run_editor(
            "edit courses", # choose the option
            "[ ] Biology (A01X)", # pick the first course
            "[ ] Economics (A03X)", # pick the second course
            "continue", # finish selecting courses
            "exit" # from the command
          )

          expect($mcb).to have_received(:run).with(%w[courses edit X12 A01X A03X])
        end

        it 'invokes course editing on courses selected by their course code' do
          allow($mcb).to receive(:run)

          run_editor(
            "edit courses", # choose the option
            "A01X", # pick the first course
            "A03X", # pick the second course
            "continue", # finish selecting courses
            "exit" # from the command
          )

          expect($mcb).to have_received(:run).with(%w[courses edit X12 A01X A03X])
        end

        it 'allows to easily select all courses' do
          allow($mcb).to receive(:run)

          run_editor("edit courses", "select all", "continue", "exit")

          expect($mcb).to have_received(:run).with(%w[courses edit X12 A01X A02X A03X])
        end

        context "(run against an Azure environment)" do
          let(:environment) { 'qa' }
          subject { described_class.new(provider: provider, requester: requester, environment: environment) }

          it 'invokes course editing in the environment that the "providers edit" command was invoked' do
            allow($mcb).to receive(:run)

            run_editor("edit courses", "[ ] Biology (A01X)", "continue", "exit")

            expect($mcb).to have_received(:run).with(%w[courses edit X12 A01X -E qa])
          end
        end
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
