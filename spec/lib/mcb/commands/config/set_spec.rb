require "rails_helper"
require "mcb_helper"

describe "mcb config set" do
  let(:name) { Faker::Name.name }

  describe "the generated config" do
    let(:config) { YAML.safe_load(File.read(MCB.config_file)) }

    it "allows setting of config variable" do
      $mcb.run(["config", "set", "name", name])

      expect(config["name"]).to eq name
    end
  end
end
