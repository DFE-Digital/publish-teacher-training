# == Schema Information
#
# Table name: site
#
#  id            :integer          not null, primary key
#  address2      :text
#  address3      :text
#  address4      :text
#  code          :text             not null
#  location_name :text
#  postcode      :text
#  address1      :text
#  provider_id   :integer          default(0), not null
#  region_code   :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe Provider, type: :model do
  subject { create(:site) }

  describe 'associations' do
    it { should belong_to(:provider) }
  end

  describe '#touch_provider' do
    let(:site) { create(:site) }

    it 'sets changed_at to the current time' do
      Timecop.freeze do
        site.touch
        expect(site.provider.changed_at).to eq Time.now.utc
      end
    end

    it 'leaves updated_at unchanged' do
      timestamp = 1.hour.ago
      site.provider.update updated_at: timestamp
      site.touch
      expect(site.provider.updated_at).to eq timestamp
    end
  end
end
