require 'spec_helper'
require 'mcb_helper'

describe 'mcb command' do
  describe '.load_commands' do
    include FakeFS::SpecHelpers

    it 'loads the files in a directory' do
      FakeFS do
        commands_lib_dir = 'lib/mcb/commands'
        FileUtils.mkdir_p(commands_lib_dir)
        FileUtils.touch("#{commands_lib_dir}/test.rb")

        cmd = Cri::Command.define { name 'mcb' }
        MCB.load_commands(cmd, commands_lib_dir)

        expect(cmd.commands.count).to eq 1
        expect(cmd.commands.first.name).to eq 'test'
      end
    end

    it 'loads the files in a sub-directories as sub-commands' do
      FakeFS do
        commands_lib_dir = 'lib/mcb/commands'
        FileUtils.mkdir_p(commands_lib_dir)
        FileUtils.touch("#{commands_lib_dir}/test.rb")
        FileUtils.mkdir_p("#{commands_lib_dir}/test")
        FileUtils.touch("#{commands_lib_dir}/test/sub.rb")

        cmd = Cri::Command.define { name 'mcb' }
        MCB.load_commands(cmd, commands_lib_dir)

        expect(cmd.commands.count).to eq 1
        expect(cmd.commands.first.name).to eq 'test'
        expect(cmd.commands.first.commands.count).to eq 1
        expect(cmd.commands.first.commands.first.name).to eq 'sub'
      end
    end

    it 'raises a helpful error if an expected command is not defined' do
      FakeFS do
        commands_lib_dir = 'lib/mcb/commands'
        FileUtils.mkdir_p(commands_lib_dir)
        FileUtils.mkdir_p("#{commands_lib_dir}/test")
        FileUtils.touch("#{commands_lib_dir}/test/sub.rb")

        cmd = Cri::Command.define { name 'mcb' }
        expect {
          MCB.load_commands(cmd, commands_lib_dir)
        }.to raise_error(
          "Command lib/mcb/commands/test.rb must be defined to have sub-commands lib/mcb/commands/test"
        )
      end
    end
  end

  describe '.apiv1_token' do
    it 'returns the token' do
      expect(MCB.apiv1_token).to eq 'bats'
    end

    context 'with the webapp option' do
      before do
        allow(MCB::Azure).to receive(:get_config)
                               .and_return('AUTHENTICATION_TOKEN' => 'bar')
      end

      it 'uses get_config to retrieve the app config' do
        expect(MCB.apiv1_token(webapp: 'az-app')).to eq 'bar'
        expect(MCB::Azure).to have_received(:get_config).with(webapp: 'az-app',
                                                              rgroup: nil)
      end
    end
  end

  describe '.generate_apiv2_token' do
    let(:email)    { 'foo@local' }
    let(:secret)   { 'bar' }

    context 'using HS256 encoding' do
      let(:encoding) { 'HS256' }

      it 'generates a valid JWT token' do
        token = MCB.generate_apiv2_token(
          email: email,
          encoding: encoding,
          secret: secret
        )
        expect(token).to eq JWT.encode({ email: email },
                                       secret,
                                       encoding)
      end

      it 'gives a friendly error when secret is nil' do
        expect {
          MCB.generate_apiv2_token(
            email: email,
            encoding: encoding,
            secret: nil
          )
        }.to raise_error(
          "Secret not provided"
        )
      end
    end
  end

  describe '.config' do
    it 'creates a config object with config_file setting' do
      allow(MCB::Config).to receive(:new).and_return('foo' => 'bar')

      MCB.config['foo']

      expect(MCB::Config)
        .to have_received(:new).with(config_file: MCB.config_file)
    end
  end

  describe '.apiv1_opts' do
    context 'with the -E flag' do
      let(:opts) { { env: 'low-cal' } }
      let(:opts_with_webapp) do
        opts.merge(
          webapp: 'weebapp',
          rgroup: 'rezgrp',
          subscription: 'sub6'
        )
      end
      let(:urls) { %w[http://web.local https://webs.local] }
      let(:config) { { "AUTHENTICATION_TOKEN" => 'jrr' } }

      before do
        allow(MCB).to(receive(:azure_env_settings_for_opts)
                        .with(opts) { |o| o.merge opts_with_webapp })
        allow(MCB).to(receive(:requesting_remote_connection?).and_return(true))

        allow(MCB::Azure).to receive(:get_urls).and_return(urls)
        allow(MCB::Azure).to receive(:get_config).and_return(config)
      end

      subject { MCB.apiv1_opts(opts) }

      it { should include url: 'http://web.local' }
      it { should include webapp: 'weebapp' }
      it { should include rgroup: 'rezgrp' }
      it { should include subscription: 'sub6' }
      it { should include token: 'jrr' }
    end
  end

  describe '.apiv2_base_url' do
    let(:opts) do
      {
        webapp: 'weebapp',
        rgroup: 'rezgrp',
        subscription: 'sub6'
      }
    end

    it 'returns the first https url on gov.uk' do
      allow(MCB::Azure).to(
        receive(:get_urls).with(opts).and_return(
          %w[http://svc.azure.net
             https://svc.azure.net
             http://svc.service.gov.uk
             https://svc.service.gov.uk]
        )
      )

      expect(MCB.apiv2_base_url(opts))
        .to eq 'https://svc.service.gov.uk/api/v2'
    end
  end
end
