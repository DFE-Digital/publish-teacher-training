require 'mcb_helper'

describe 'mcb providers list' do
  let(:list) { MCBCommand.new('providers', 'list') }

  let(:current_cycle) { RecruitmentCycle.current_recruitment_cycle }
  let(:additional_cycle) { find_or_create(:recruitment_cycle, year: '2020') }

  context 'when recruitment cycle is unspecified' do
    let(:provider1) { create(:provider, recruitment_cycle: current_cycle) }
    let(:provider2) { create(:provider, recruitment_cycle: current_cycle) }
    let(:provider3) { create(:provider, recruitment_cycle: additional_cycle) }

    it 'lists all courses for the default recruitment cycle' do
      provider1
      provider2
      provider3

      command_output = list.execute[:stdout]

      expect(command_output).to include(provider1.provider_code)
      expect(command_output).to include(provider1.provider_name)

      expect(command_output).to include(provider2.provider_code)
      expect(command_output).to include(provider2.provider_name)

      expect(command_output).not_to include(provider3.provider_name)
      expect(command_output).not_to include(provider3.provider_code)
    end

    context 'when provider is specified' do
      it 'displays the provider information' do
        provider1
        provider2

        command_output = list.execute(arguments: [provider1.provider_code])[:stdout]

        expect(command_output).to include(provider1.provider_code)
        expect(command_output).to include(provider1.provider_name)

        expect(command_output).not_to include(provider2.provider_code)
        expect(command_output).not_to include(provider2.provider_name)
      end

      it 'displays multiple specified providers' do
        provider1
        provider2

        command_output = list.execute(arguments: [provider1.provider_code, provider2.provider_code])[:stdout]

        expect(command_output).to include(provider1.provider_code)
        expect(command_output).to include(provider1.provider_name)

        expect(command_output).to include(provider2.provider_code)
        expect(command_output).to include(provider2.provider_name)
      end

      it 'is case insensitive' do
        provider1
        provider2

        command_output = list.execute(arguments: [provider1.provider_code.downcase])[:stdout]
        expect(command_output).to include(provider1.provider_code)
      end
    end

    context 'when provider is unspecified' do
      it 'displays information about providers for the current recruitment cycle' do
        provider1
        provider2

        command_output = list.execute[:stdout]

        expect(command_output).to include(provider1.provider_code)
        expect(command_output).to include(provider1.provider_name)

        expect(command_output).to include(provider2.provider_code)
        expect(command_output).to include(provider2.provider_name)
      end
    end
  end

  context 'when recruitment cycle is specified' do
    let(:provider1) { create(:provider, recruitment_cycle: current_cycle) }
    let(:provider2) { create(:provider, recruitment_cycle: additional_cycle) }

    it 'displays information about providers for the specified recruitment cycle' do
      provider1
      provider2

      command_output = list.execute(arguments: ["-r", additional_cycle.year])[:stdout]
      expect(command_output).to include(provider2.provider_code)
      expect(command_output).to include(provider2.provider_name)

      expect(command_output).not_to include(provider1.provider_code)
      expect(command_output).not_to include(provider1.provider_code)
    end
  end
end
