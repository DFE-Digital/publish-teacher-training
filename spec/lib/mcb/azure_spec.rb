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

    subject { MCB::Azure.get_config('some-app', 'some-rgroup') }

    before :each do
      allow(MCB).to receive(:run_command).and_return(config_json)
    end

    it 'runs az' do
      subject
      expect(MCB).to(
        have_received(:run_command).with(
          'az webapp config appsettings list -g some-rgroup -n some-app'
        )
      )
    end

    it { should eq('SETTING_ONE' => 'UNO', 'SETTING_TWO' => 'DUO') }
  end

  describe '.configure_database' do
    before :each do
      allow(ENV).to receive(:[]=)
      allow(MCB::Azure).to(
        receive(:get_apps).and_return([{
                                         'name' => 'noapp',
                                         'resourceGroup' => 'rgrrroup'
                                       }])
      )

      allow(MCB::Azure).to(
        receive(:get_config).and_return(
          'MANAGE_COURSES_POSTGRESQL_SERVICE_HOST' => 'host',
          'PG_DATABASE'                            => 'pgdb',
          'PG_USERNAME'                            => 'user',
          'PG_PASSWORD'                            => 'pass',
        )
      )
    end

    subject { MCB::Azure.configure_database('noapp') }

    it 'sets the env variables to the app settings' do
      subject
      expect(ENV).to have_received(:[]=).with('DB_HOSTNAME', 'host')
      expect(ENV).to have_received(:[]=).with('DB_DATABASE', 'pgdb')
      expect(ENV).to have_received(:[]=).with('DB_USERNAME', 'user')
      expect(ENV).to have_received(:[]=).with('DB_PASSWORD', 'pass')
    end
  end
end
