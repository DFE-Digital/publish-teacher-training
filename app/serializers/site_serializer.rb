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
