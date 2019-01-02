class SiteSerializer < ActiveModel::Serializer
  attributes :campus_code, :name, :recruitment_cycle

  def campus_code
    object.code
  end

  def name
    object.location_name
  end

  # TODO: make recruitment cycle dynamic
  def recruitment_cycle
    {
      "name" => "2019/20"
    }
  end
end
