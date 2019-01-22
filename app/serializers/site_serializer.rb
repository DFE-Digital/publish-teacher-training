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

class SiteSerializer < ActiveModel::Serializer
  attributes :campus_code, :name, :region_code

  def campus_code
    object.code
  end

  def name
    object.location_name
  end

  def region_code
    '%02d' % object.region_code_before_type_cast if object.region_code.present?
  end
end
