module SearchAndCompare
  class ProviderSerializer < ActiveModel::Serializer
    attribute(:Id) { object.id }
  end
end
