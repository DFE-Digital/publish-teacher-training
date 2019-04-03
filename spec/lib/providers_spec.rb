require 'spec_helper'
load 'bin/mcb'

describe 'mcb providers' do
  describe '--webapp option' do
    let(:app_config) do
      {
        'RAILS_ENV' => 'aztest'
      }
    end
    let(:expected_rails_env) { 'aztest' }

    before do
      allow(MCB::Azure).to receive(:get_config).and_return(app_config)
      allow(MCB::Azure).to receive(:configure_database)
    end

    subject do
      with_stubbed_stdout(stdin: expected_rails_env) do
        $mcb.run(%w[providers --webapp=banana])
      end
    end

    it 'configures the database' do
      subject

      expect(MCB::Azure).to have_received(:get_config).with('banana')
      expect(MCB::Azure).to have_received(:configure_database)
                              .with('banana', app_config: app_config)
    end

    it 'prompts for the expected RAILS_ENV' do
      output = subject

      expect(output).to match %r{enter the expected RAILS_ENV for banana:}
    end

    context 'expected RAILS_ENV does not match' do
      let(:expected_rails_env) { 'qa' }

      it 'raises an error if the expected RAILS_ENV does not match' do
        expect { subject } .to raise_error(RuntimeError)
      end
    end
  end
end
