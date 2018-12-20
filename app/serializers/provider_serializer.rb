class ProviderSerializer < ActiveModel::Serializer
  has_many :sites, key: :campuses

  attributes :institution_code, :institution_name,
             :institution_type, :accrediting_provider

  def institution_code
    object.provider_code
  end

  def institution_name
    object.provider_name
  end

  def institution_type
    'Y' # TODO: wire up data
  end

  def accrediting_provider
    # TODO: pull this thru from UCAS import
  end
end
