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

class Site < ApplicationRecord
  include RegionCode
  include TouchProvider

  belongs_to :provider

  validates :location_name, uniqueness: { scope: :provider }
  validates :location_name,
            :address1,
            :address3,
            :postcode,
            presence: true
end
