# == Schema Information
#
# Table name: organisation
#
#  id     :integer          not null, primary key
#  name   :text
#  org_id :text
#

require 'rails_helper'

RSpec.describe Organisation, type: :model do
  subject { create(:organisation) }

  describe 'associations' do
    it { should have_and_belong_to_many(:users) }
    it { should have_and_belong_to_many(:providers) }
  end
end
