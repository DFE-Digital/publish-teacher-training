module SearchAndCompare
  class ProviderSerializer < ActiveModel::Serializer
    # Provider_default_value_Mapping
    attribute(:Id)                                    { 0 }
    attribute(:Courses)                               { nil }
    attribute(:AccreditedCourses)                     { nil }

    # Provider_direct_simple_Mapping
    attribute(:Name)                                  { object.provider_name }
    attribute(:ProviderCode)                          { object.provider_code }
  end
end
