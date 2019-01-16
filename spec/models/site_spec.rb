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
#

require 'rails_helper'

RSpec.describe Provider, type: :model do
  subject { create(:site) }

  describe 'associations' do
    it { should belong_to(:provider) }
  end
end
