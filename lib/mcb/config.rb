require 'active_support/hash_with_indifferent_access'

module MCB
  class Config < ActiveSupport::HashWithIndifferentAccess
    def initialize(config_file:)
      @config_file = config_file if config_file
      @config_dir  = File.dirname(File.expand_path(config_file))
      load
    end

    def save
      FileUtils.mkdir_p(File.expand_path(@config_dir))

      File.open(File.expand_path(@config_file), 'w', 0o600) do |f|
        f.write(YAML.dump(to_h))
      end
    end

  private

    def load
      if File.exist? @config_file
        new_config = YAML.safe_load(File.read(@config_file))
        update(new_config || {})
      end
    end
  end
end
