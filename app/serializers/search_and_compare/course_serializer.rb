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
      object.dfe_subjects.map do |subject_name|
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
              Name: subject_name,
            }
        }
      end
    end

    attribute(:Route)                                 { get_route }
    attribute(:IsSalaried)                            { is_salaried? }
    attribute(:Mod)                                   { object.description }
    attribute(:IncludesPgce)                          { get_include_pgce }

    attribute(:FullTime)                              { object.part_time? ? 3 : 1 }
    attribute(:PartTime)                              { object.full_time? ? 3 : 1 }

    def get_route
      route_names = {
        higher_education_programme: "Higher education programme",
        school_direct_training_programme: "School Direct training programme",
        school_direct_salaried_training_programme: "School Direct (salaried) training programme",
        scitt_programme: "SCITT programme",
        pg_teaching_apprenticeship: "PG Teaching Apprenticeship",
      }

      {
        # Route_default_value_Mapping
        Id: 0,
        Courses: nil,
        # Route_Complex_value_Mapping
        Name: route_names[object.program_type.to_sym],
        IsSalaried: is_salaried?
      }
    end

    def is_salaried?
      !object.is_fee_based?
    end

    def get_include_pgce
      include_pgces = {
        qts: 0,
        pgce_with_qts: 1,
        pgde_with_qts: 3,
        pgce: 5,
        pgde: 6,
      }

      include_pgces[object.qualification.to_sym]
    end
  end
end
