require 'mcb_helper'

describe 'mcb providers list' do
  def list(*arguments)
    stderr = nil
    output = with_stubbed_stdout(stdin: "", stderr: stderr) do
      $mcb.run %W[courses list] + arguments
    end
    { stdout: output, stderr: stderr }
  end

  let(:current_cycle) { RecruitmentCycle.current_recruitment_cycle }
  let(:additional_cycle) { find_or_create(:recruitment_cycle, year: '2020') }

  context 'when recruitment cycle is unspecified' do
    let(:provider1) { create(:provider, provider_code: 'X13', provider_name: 'Learning Provider', recruitment_cycle: current_cycle) }
    let(:provider2) { create(:provider, provider_code: 'A12', provider_name: 'Provider of Learning', recruitment_cycle: current_cycle) }

    let(:course1) { create(:course, provider: provider1, course_code: 'Y2K', name: "New course") }
    let(:course2) { create(:course, provider: provider2, course_code: 'M33', name: "Later course") }

    context 'when course is specified' do
      it 'displays the provider information' do
        course1
        course2

        command_output = list('Y2K')[:stdout]

        expect(command_output).to match(/Y2K/)
        expect(command_output).to match(/New course/)

        expect(command_output).not_to match(/M33/)
        expect(command_output).not_to match(/Later course/)
      end

      it 'displays all specified providers' do
        course1
        course2

        command_output = list('Y2K', 'M33')[:stdout]

        expect(command_output).to match(/Y2K/)
        expect(command_output).to match(/New course/)

        expect(command_output).to match(/M33/)
        expect(command_output).to match(/Later course/)
      end

      it 'is case insensitive' do
        course1
        course2

        command_output = list('m33')[:stdout]
        expect(command_output).to match(/M33/)
      end
    end

    context 'when provider is unspecified' do
      it 'displays information about courses for the current recruitment cycle' do
        course1
        course2

        command_output = list[:stdout]

        expect(command_output).to match(/Y2K/)
        expect(command_output).to match(/New course/)

        expect(command_output).to match(/M33/)
        expect(command_output).to match(/Later course/)
      end
    end
  end

  context 'when recruitment cycle is specified' do
    let(:provider1) { create(:provider, provider_code: 'A12', provider_name: 'Provider of Learning', recruitment_cycle: current_cycle) }
    let(:provider2) { create(:provider, provider_code: 'X13', provider_name: 'Learning Provider', recruitment_cycle: additional_cycle) }

    let(:course1) { create(:course, provider: provider1, course_code: 'Y2K', name: "New course") }
    let(:course2) { create(:course, provider: provider2, course_code: 'M33', name: "Later course") }

    it 'displays information about courses for the specified recruitment cycle' do
      course1
      course2

      command_output = list("-R", additional_cycle.year)[:stdout]

      expect(command_output).to match(/M33/)
      expect(command_output).to match(/Later course/)

      expect(command_output).not_to match(/Y2K/)
      expect(command_output).not_to match(/New course/)
    end
  end
end
