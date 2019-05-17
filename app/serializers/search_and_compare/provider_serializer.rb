module SearchAndCompare
  class ProviderSerializer < ActiveModel::Serializer
    # Course_default_value_Mapping
    attribute(:Id)                                    { 0 }
    attribute(:Courses)                               { nil }
    attribute(:AccreditedCourses)                     { nil }

    attribute(:Name)                                  { object.provider_name }
    attribute(:ProviderCode)                          { object.provider_code }
  end
end
