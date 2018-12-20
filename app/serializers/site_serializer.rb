class SiteSerializer < ActiveModel::Serializer
  attributes :campus_code, :name

  def campus_code
    object.code
  end

  def name
    object.location_name
  end
end
