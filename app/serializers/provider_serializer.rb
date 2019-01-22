# == Schema Information
#
# Table name: provider
#
#  id                   :integer          not null, primary key
#  provider_name        :text
#  provider_code        :text
#  provider_type        :text
#  scheme_member        :text
#  year_code            :text
#  scitt                :text
#  accrediting_provider :text
#  contact_name         :text
#  address1             :text
#  address2             :text
#  address3             :text
#  address4             :text
#  postcode             :text
#  email                :text
#  telephone            :text
#  url                  :text
#

class ProviderSerializer < ActiveModel::Serializer
  has_many :sites, key: :campuses

  attributes :institution_code, :institution_name, :institution_type, :accrediting_provider,
             :address1, :address2, :address3, :address4, :postcode, :region_code

  def institution_code
    object.provider_code
  end

  def institution_name
    object.provider_name
  end

  def institution_type
    object.provider_type_before_type_cast
  end

  def address1
    object.address_info['address1']
  end

  def address2
    object.address_info['address2']
  end

  def address3
    object.address_info['address3']
  end

  def address4
    object.address_info['address4']
  end

  def postcode
    object.address_info['postcode']
  end

  def region_code
    "%02d" % object.address_info['region_code'] if object.address_info['region_code'].present?
  end
end
