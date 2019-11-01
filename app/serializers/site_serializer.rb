# == Schema Information
#
# Table name: site
#
#  address1      :text
#  address2      :text
#  address3      :text
#  address4      :text
#  code          :text             not null
#  created_at    :datetime         not null
#  id            :integer          not null, primary key
#  location_name :text
#  postcode      :text
#  provider_id   :integer          default(0), not null
#  region_code   :integer
#  updated_at    :datetime         not null
#
# Indexes
#
#  IX_site_provider_id_code  (provider_id,code) UNIQUE
#

class SiteSerializer < ActiveModel::Serializer
  attributes :campus_code, :name, :region_code

  def campus_code
    object.code
  end

  def name
    object.location_name
  end

  def region_code
    "%02d" % object.region_code_before_type_cast if object.region_code.present?
  end
end
