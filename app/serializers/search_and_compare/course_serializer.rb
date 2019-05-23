module SearchAndCompare
  class CourseSerializer < ActiveModel::Serializer
    # Provider_serializer_Mapping
    # Covered by
    has_one :provider, key: :Provider, serializer: SearchAndCompare::ProviderSerializer
    has_one :accrediting_provider, key: :AccreditingProvider, serializer: SearchAndCompare::ProviderSerializer

    # TODO: After completion
    # TASK: Anything that return (ie. default_xxx_value, or attribute(:xxx))
    #         (int)             0
    #         (reference type)  nil
    #         (bool)            false
    #         (date)            '0001-01-01T00:00:00'
    #       applies to SearchAndCompare::ProviderSerializer
    #
    #       snc should just hydrate default values when omitted
    #
    # TASK: strftime('%Y-%m-%dT%H:%M:%S')
    #       double check that this can be removed
    #       as long as its a valid date format it should work in snc
    # TASK: see attribute(:Route)
    # TASK: see attribute(:Salary)

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
    # using server date time not utc, so it's local date time?
    attribute(:StartDate)                             { object.start_date.utc.strftime('%Y-%m-%dT%H:%M:%S') }

    # Salary_nested_default_value_Mapping
    # TODO: After completion
    # TASK: Double check is Salary actual in use in snc else drop it
    attribute(:Salary)                                { default_salary_value }

    # Subjects_related_Mapping
    attribute(:IsSen)                                 { object.is_send? }
    attribute(:CourseSubjects)                        { course_subjects }

    # Course_variant_Mapping
    # TODO: After completion
    # TASK: Route.Name can be blank, snc needs to relax blank rule
    #       Route.Name can be dropped, snc don't use it
    #       Course.Route.IsSalaried should become Course.IsSalaried
    #       Then Route
    #       Route can be dropped altogether in snc
    attribute(:Route)                                 { route }

    attribute(:IsSalaried)                            { is_salaried? }
    attribute(:Mod)                                   { object.description }
    attribute(:IncludesPgce)                          { include_pgce }

    attribute(:FullTime)                              { object.part_time? ? 3 : 1 }
    attribute(:PartTime)                              { object.full_time? ? 3 : 1 }


    # Campuses_related_Mapping
    attribute(:Campuses)                              { campuses }
    # using server date time not utc, so it's local date time?
    attribute(:ApplicationsAcceptedFrom)              { object.applications_open_from.to_date.strftime('%Y-%m-%dT%H:%M:%S') }
    attribute(:HasVacancies)                          { object.has_vacancies? }

  private

    def course_subjects
      # CourseSubject_Mapping
      object.dfe_subjects.map do |subject|
        {
          **default_course_subjects_value,
          Subject:
            {
              **default_subject_value,
              Name: subject.to_s,
            }
        }
      end
    end

    def default_route_value
      {
        Id: 0,
        Courses: nil,
      }
    end

    def route
      route_names = {
        higher_education_programme: "Higher education programme",
        school_direct_training_programme: "School Direct training programme",
        school_direct_salaried_training_programme: "School Direct (salaried) training programme",
        scitt_programme: "SCITT programme",
        pg_teaching_apprenticeship: "PG Teaching Apprenticeship",
      }

      {
        **default_route_value,
        Name: route_names[object.program_type.to_sym],
        IsSalaried: is_salaried?
      }
    end

    def is_salaried?
      !object.is_fee_based?
    end

    def include_pgce
      include_pgces = {
        qts: 0,
        pgce_with_qts: 1,
        pgde_with_qts: 3,
        pgce: 5,
        pgde: 6,
      }

      include_pgces[object.qualification.to_sym]
    end

    def full_address(address1:, address2:, address3:, address4:, postcode:)
      [address1, address2, address3, address4, postcode].reject(&:blank?).join('/n')
    end

    def campuses
      object.site_statuses.findable.map do |site_status|
        raw_address = { address1: site_status.site.address1, address2: site_status.site.address2, address3: site_status.site.address3, address4: site_status.site.address4, postcode: site_status.site.postcode }

        address = full_address(raw_address)

        {
          **default_campus_value,
          VacStatus: site_status.vac_status_before_type_cast,
          Name: site_status.site.location_name,
          CampusCode: site_status.site.code,
          Location: { **default_location_value, Address: address }
        }
      end
    end

    def default_salary_value
      {
        Minimum: nil,
        Maximum: nil,
      }
    end

    def default_subject_value
      {
        Id: 0,
        SubjectArea: nil,
        FundingId: nil,
        Funding: nil,
        IsSubjectKnowledgeEnhancementAvailable: false,
        CourseSubjects: nil,
      }
    end

    def default_course_subjects_value
      {
        CourseId: 0,
        Course: nil,
        SubjectId: 0,
      }
    end

    def default_campus_value
      {
        Id: 0,
        LocationId: nil,
        Course: nil,
      }
    end

    def default_location_value
      {
        Id: 0,
        FormattedAddress: nil,
        GeoAddress: nil,
        Latitude: nil,
        Longitude: nil,
        LastGeocodedUtc: '0001-01-01T00:00:00'
      }
    end
  end
end
