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

class SiteSerializer < ActiveModel::Serializer
  attributes :campus_code, :name, :region_code, :recruitment_cycle

  def campus_code
    object.code
  end

  def name
    object.location_name
  end

  def region_code
    '%02d' % object.region_code_before_type_cast if object.region_code.present?
  end

  # TODO: make recruitment cycle dynamic
  def recruitment_cycle
    "2019"
  end
end
