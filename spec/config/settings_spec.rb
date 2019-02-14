require 'rails_helper'

describe Settings do
  describe 'authentication' do
    subject do
      YAML.load_file(File.join(Rails.root, 'config', 'settings.yml'))
    end

    its(%w[authentication algorithm]) { should eq 'HS256' }
    its(%w[authentication secret])    { should eq '<%= SecureRandom.base64 %>' }
  end
end
