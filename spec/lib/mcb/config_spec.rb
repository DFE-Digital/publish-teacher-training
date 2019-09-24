require "mcb_helper"

describe MCB::Config do
  let(:config_file) { Tempfile.new(["mcb_cli_config_", ".yml"]) }

  describe "accessing keys" do
    it "keys are accessible as strings or symbols" do
      config = MCB::Config.new(config_file: config_file.path)
      config["cat"] = "meow"
      expect(config[:cat]).to eq "meow"
    end
  end

  describe "writing keys" do
    it "converts keys to strings" do
      config = MCB::Config.new(config_file: config_file.path)
      config[:dog] = "woof"
      expect(config["dog"]).to eq "woof"
    end
  end

  describe "initialize" do
    let(:config) { { "foo" => "bar" } }

    it "loads the config file" do
      config_file.write(config.to_yaml)
      config_file.close

      conf = MCB::Config.new(config_file: config_file.path)
      expect(conf["foo"]).to eq "bar"
    end
  end

  describe ".save" do
    it "writes safe YAML to the config file" do
      config_file.close

      config = MCB::Config.new(config_file: config_file.path)
      config[:door] = "knob"
      config.save

      saved_config = YAML.safe_load(File.read(config_file.path))
      expect(saved_config["door"]).to eq "knob"
    end
  end
end
