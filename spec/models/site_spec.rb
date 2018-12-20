require 'rails_helper'

RSpec.describe Provider, type: :model do
  subject { create(:site) }

  describe 'associations' do
    it { should belong_to(:provider) }
  end
end
