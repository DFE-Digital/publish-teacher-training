require 'rails_helper'

RSpec.describe Course, type: :model do
  subject { create(:course) }

  describe 'associations' do
    it { should belong_to(:provider) }
    it { should belong_to(:accrediting_provider) }
  end
end
