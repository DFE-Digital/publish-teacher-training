require 'mcb_helper'

describe 'mcb providers list' do
  def list(*arguments)
    stderr = nil
    output = with_stubbed_stdout(stdin: "", stderr: stderr) do
      $mcb.run %W[provider list] + arguments
    end
    { stdout: output, stderr: stderr }
  end

  let(:email) { 'user@education.gov.uk' }

  before do
    allow(MCB).to receive(:config).and_return(email: email)
  end

  let(:current_cycle) { RecruitmentCycle.current_recruitment_cycle }
  let(:additional_cycle) { find_or_create(:recruitment_cycle, year: '2020') }

  context 'when recruitment cycle is unspecified' do
    let(:provider1) { create(:provider, provider_code: 'X13', provider_name: 'Learning Provider', recruitment_cycle: current_cycle) }
    let(:provider2) { create(:provider, provider_code: 'A12', provider_name: 'Provider of Learning', recruitment_cycle: current_cycle) }
    context 'when provider is specified' do
      it 'displays the provider information' do
        provider1
        provider2

        command_output = list('X13')[:stdout]

        expect(command_output).to match(/X13/)
        expect(command_output).to match(/Learning Provider/)

        expect(command_output).not_to match(/A12/)
        expect(command_output).not_to match(/Provider of Learning/)
      end

      it 'displays all specified providers' do
        provider1
        provider2

        command_output = list('X13', 'A12')[:stdout]

        expect(command_output).to match(/X13/)
        expect(command_output).to match(/Learning Provider/)

        expect(command_output).to match(/A12/)
        expect(command_output).to match(/Provider of Learning/)
      end
    end

    context 'when provider is unspecified' do
      it 'displays information about providers for the current recruitment cycle' do
        provider1
        provider2

        command_output = list[:stdout]

        expect(command_output).to match(/A12/)
        expect(command_output).to match(/Provider of Learning/)

        expect(command_output).to match(/X13/)
        expect(command_output).to match(/Learning Provider/)
      end
    end
  end

  context 'when recruitment cycle is specified' do
    let(:provider1) { create(:provider, provider_code: 'A12', provider_name: 'Provider of Learning', recruitment_cycle: current_cycle) }
    let(:provider2) { create(:provider, provider_code: 'X13', provider_name: 'Learning Provider', recruitment_cycle: additional_cycle) }

    it 'displays information about providers for the specified recruitment cycle' do
      provider1
      provider2

      command_output = list("-R", additional_cycle.year)[:stdout]
      expect(command_output).to match(/X13/)
      expect(command_output).to match(/Learning Provider/)

      expect(command_output).not_to match(/A12/)
      expect(command_output).not_to match(/Provider of Learning/)
    end
  end
end
