require 'spec_helper'
require 'mcb_helper'

describe 'running the mcb script' do
  describe 'config flag' do
    let(:config_file) { Tempfile.new(['new_config_file', '.yml']) }
    let(:config)      { { 'new' => 'day' } }

    it 'can set the path to the config file' do
      result = with_stubbed_stdout do
        File.write config_file.path, config.to_yaml
        $mcb.run(%W[-c #{config_file.path} config show])
      end

      expect(MCB.config_file).to eq config_file.path
      expect(result).to eq config.to_yaml
    end
  end
end
