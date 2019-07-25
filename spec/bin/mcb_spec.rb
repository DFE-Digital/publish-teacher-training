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

  describe 'REPL' do
    it 'provides completions for empty prompt' do
      output = with_stubbed_stdout(stdin: "\t\t") do
        MCB.start_mcb_repl([])
      end

      expect(output).to include("providers")
      expect(output).to include("console")
      expect(output).to include("courses")
      expect(output).to include("config")
      expect(output).to include("apiv1")
      expect(output).to include("apiv2")
      expect(output).to include("users")
      expect(output).to include("az")
    end

    it 'provides relevant completions for a main command' do
      output = with_stubbed_stdout(stdin: "co\t\t") do
        MCB.start_mcb_repl([])
      end

      expect(output).not_to include("providers")
      expect(output).to include("console")
      expect(output).to include("courses")
      expect(output).to include("config")
      expect(output).not_to include("apiv1")
      expect(output).not_to include("apiv2")
      expect(output).not_to include("users")
      expect(output)
    end
  end
end
