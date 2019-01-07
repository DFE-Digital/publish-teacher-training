class ProviderSerializer < ActiveModel::Serializer
  has_many :sites, key: :campuses

  attributes :institution_code, :institution_name, :institution_type, :accrediting_provider,
             :address1, :address2, :address3, :address4, :postcode

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

  def address1
    if object.enrichments.present?
      object.enrichments.last.json_data["Address1"]
    else
      object.address1
    end
  end

  def address2
    if object.enrichments.present?
      object.enrichments.last.json_data["Address2"]
    else
      object.address2
    end
  end

  def address3
    if object.enrichments.present?
      object.enrichments.last.json_data["Address3"]
    else
      object.address3
    end
  end

  def address4
    if object.enrichments.present?
      object.enrichments.last.json_data["Address4"]
    else
      object.address4
    end
  end

  def postcode
    if object.enrichments.present?
      object.enrichments.last.json_data["Postcode"]
    else
      object.postcode
    end
  end
end
