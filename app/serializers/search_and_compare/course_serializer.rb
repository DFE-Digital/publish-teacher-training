module SearchAndCompare
  class CourseSerializer < ActiveModel::Serializer
    # Provider_serializer_Mapping
    # Covered by
    has_one :provider, key: :Provider, serializer: SearchAndCompare::ProviderSerializer
    has_one :accrediting_provider, key: :AccreditingProvider, serializer: SearchAndCompare::ProviderSerializer

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

    # Course_direct_simple_Mapping
    attribute(:Name)                                  { object.name }
    attribute(:ProgrammeCode)                         { object.course_code }
    # using server time not utc, so it's local time?
    attribute(:StartDate)                             { object.start_date.utc.strftime('%Y-%m-%dT%H:%M:%S') }


    # Salary_nested_default_value_Mapping
    attribute(:Salary)                                { default_salary }

    def default_salary
      {
        Minimum: nil,
        Maximum: nil,
      }
    end

    # Subjects_related_Mapping
    attribute(:IsSen)                                 { object.is_send? }
    attribute(:CourseSubjects)                        { get_subjects }

    def get_subjects
      # CourseSubject_Mapping
      object.dfe_subjects.map do |subject|
        {
          # CourseSubject_default_value_mapping
          CourseId: 0,
          Course: nil,
          SubjectId: 0,
          # CourseSubject_complex
          Subject:
            {
              # Subject_default_value_Mapping
              Id: 0,
              SubjectArea: nil,
              FundingId: nil,
              Funding: nil,
              IsSubjectKnowledgeEnhancementAvailable: false,
              CourseSubjects: nil,

              # Subject_direct_Mapping
              Name: subject.to_s,
            }
        }
      end
    end
  end
end
