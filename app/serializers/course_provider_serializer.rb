class CourseProviderSerializer < ActiveModel::Serializer
  has_many :sites, key: :campuses

  attributes :institution_code, :institution_name, :institution_type, :accrediting_provider,
             :scheme_member

  def institution_code
    object.provider_code
  end

  def institution_name
    object.provider_name
  end

  def institution_type
    object.provider_type_before_type_cast
  end

  def accrediting_provider
    object.accrediting_provider_before_type_cast
  end

  def scheme_member
    object.scheme_member_before_type_cast
  end
end
