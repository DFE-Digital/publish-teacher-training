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

  describe 'validations' do
    subject { build(:organisation, name: name) }

    context 'when name is empty string' do
      let(:name) { '  ' }

      it { should_not be_valid }
    end

    context 'when name is nil' do
      let(:name) { nil }

      it { should_not be_valid }
    end

    context 'when name is a school' do
      let(:name) { 'High School' }

      it { should be_valid }
    end
  end
end
