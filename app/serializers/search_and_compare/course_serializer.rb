module SearchAndCompare
  class CourseSerializer < ActiveModel::Serializer
    # Course_default_value_Mapping
    attribute(:Id)                                    { 0 }
    attribute(:ProviderCodeName)                      { nil }
    attribute(:ProviderId)                            { 0 }
    attribute(:AccreditingProviderId)                 { nil }
    attribute(:AgeRange)                              { 0 }
    attribute(:RouteId)                               { 0 }
    attribute(:ProviderLocationId)                    { nil }
    attribute(:Distance)                              { nil }
    attribute(:DistanceAddress)                       { nil }
    attribute(:ContactDetailsId)                      { nil }
  end
end
