class ProviderSerializer < ActiveModel::Serializer
  has_many :sites, key: :campuses

  attributes :institution_code, :institution_name, :institution_type, :accrediting_provider,
             :address1, :address2, :address3, :address4, :postcode

  def institution_code
    object.provider_code
  end

  def institution_name
    {
      "full" => object.provider_name,
      "long" => object.provider_name[0..19],
      "short" => object.provider_name[0..5],
    }
  end

  def institution_type
    object.provider_type_before_type_cast
  end

  def accrediting_provider
    # TODO: pull this thru from UCAS import
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
end
