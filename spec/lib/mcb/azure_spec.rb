require 'spec_helper'
require "#{Rails.root}/lib/mcb"
require "#{Rails.root}/lib/mcb/azure"

describe MCB::Azure do
  describe '.get_subs' do
    let(:subs_json) do
      <<~EOSUBS
        [
          {
            "cloudName": "AzureCloud",
            "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
            "name": "Development"
          },
          {
            "cloudName": "AzureCloud",
            "id": "cccccccc-cccc-cccc-cccc-cccccccccccc",
            "name": "Production"
          }
        ]
      EOSUBS
    end

    subject { MCB::Azure.get_subs }

    before :each do
      allow(MCB).to receive(:run_command).and_return(subs_json)
    end

    it 'runs az' do
      subject
      expect(MCB).to have_received(:run_command).with('az account list')
    end

    it { should eq JSON.parse(subs_json) }
  end

  describe '.get_apps' do
    let(:apps_json) do
      <<~EOAPPS
        [
          {
             "name": "app-prod",
             "kind": "app,linux,container",
             "enabled": true
          },
          {
             "name": "app-dev",
             "kind": "app,linux,container",
             "enabled": true
          }
        ]
      EOAPPS
    end

    subject { MCB::Azure.get_apps }

    before :each do
      allow(MCB).to receive(:run_command).and_return(apps_json)
    end

    it 'runs az' do
      subject
      expect(MCB).to have_received(:run_command).with('az webapp list')
    end

    it { should eq JSON.parse(apps_json) }
  end

  describe '.get_config' do
    let(:config_json) do
      <<~EOCONFIG
        [
          {
            "name": "SETTING_ONE",
            "value": "UNO"
          },
          {
            "name": "SETTING_TWO",
            "value": "DUO"
          }
        ]
      EOCONFIG
    end

    subject { MCB::Azure.get_config('some-app', rgroup: 'some-rgroup') }

    before :each do
      allow(MCB).to receive(:run_command).and_return(config_json)
    end

    it 'runs az' do
      subject
      expect(MCB).to(
        have_received(:run_command).with(
          "az webapp config appsettings list -g 'some-rgroup' -n 'some-app'"
        )
      )
    end

    it { should eq('SETTING_ONE' => 'UNO', 'SETTING_TWO' => 'DUO') }
  end

  describe '.configure_database' do
    let(:app_config) do
      {
        'MANAGE_COURSES_POSTGRESQL_SERVICE_HOST' => 'host',
        'PG_DATABASE'                            => 'pgdb',
        'PG_USERNAME'                            => 'user',
        'PG_PASSWORD'                            => 'pass',
      }
    end

    before :each do
      allow(ENV).to receive(:[]=)
      allow(MCB::Azure).to(
        receive(:get_apps).and_return([{
                                        'name' => 'noapp',
                                         'resourceGroup' => 'rgrrroup'
                                      }])
      )

      allow(MCB::Azure).to(receive(:get_config).and_return(app_config))
    end

    subject { MCB::Azure.configure_database(app_config) }

    it 'sets the env variables to the app settings' do
      subject
      expect(ENV).to have_received(:[]=).with('DB_HOSTNAME', 'host')
      expect(ENV).to have_received(:[]=).with('DB_DATABASE', 'pgdb')
      expect(ENV).to have_received(:[]=).with('DB_USERNAME', 'user')
      expect(ENV).to have_received(:[]=).with('DB_PASSWORD', 'pass')
    end
  end

  describe '.configure_env' do
    it 'sets all the SETTINGS__ env vars from the app config' do
      allow(ENV).to receive(:update)
      MCB::Azure.configure_env(
        'SETTINGS__FOO' => 'bar',
        'some_random_kind_of_yak' => 'shaving'
      )
      expect(ENV).to(
        have_received(:update).with(
          'SETTINGS__FOO' => 'bar',
        )
      )
    end
  end

  describe '.configure_for_webapp' do
    let(:app_config) do
      {
        'RAILS_ENV' => 'aztest'
      }
    end
    let(:expected_rails_env) { 'aztest' }
    let(:output) do
      with_stubbed_stdout(stdin: expected_rails_env) do
        MCB::Azure.configure_for_webapp(webapp: 'banana')
      end
    end


    before do
      allow(MCB::Azure).to receive(:get_config).and_return(app_config)
      allow(MCB::Azure).to receive(:configure_database)
      allow(MCB::Azure).to receive(:rgroup_for_app).and_return('banana-tree')
    end

    subject { output }

    it 'prompts for the expected RAILS_ENV' do
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
