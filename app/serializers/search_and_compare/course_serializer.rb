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
    # TASK: see attribute(:AgeRange)

    # Course_default_value_Mapping
    attribute(:Id)                                    { 0 }
    attribute(:ProviderCodeName)                      { nil }
    attribute(:ProviderId)                            { 0 }
    attribute(:AccreditingProviderId)                 { nil }

    # TODO: After completion
    # TASK: Double check is it actual in use in snc else drop it
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
    attribute(:StartDate)                             { object.start_date&.utc&.strftime("%Y-%m-%dT%H:%M:%S") }

    # Salary_nested_default_value_Mapping
    # TODO: After completion
    # TASK: Double check is it actual in use in snc else drop it
    attribute(:Salary)                                { default_salary_value }

    # Subjects_related_Mapping
    attribute(:IsSen)                                 { object.is_send? }
    attribute(:CourseSubjects)                        { course_subjects }

    # Course_variant_Mapping
    # TODO: After completion
    # TASK: Route.Name can be blank, snc needs to relax blank rule
    #       Route.Name can be dropped, snc don't use it
    #       Course.Route.IsSalaried should become Course.IsSalaried
    #       Then
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
    attribute(:ApplicationsAcceptedFrom)              { object.applications_open_from&.to_date&.strftime("%Y-%m-%dT%H:%M:%S") }
    attribute(:HasVacancies)                          { object.has_vacancies? }

    # Course_direct_enrichment_Mapping
    attribute(:Duration)                              { duration }
    attribute(:Fees)                                  { fees }

    # Provider_contact_info_Mapping
    attribute(:ProviderLocation)                      { provider_location }
    attribute(:ContactDetails)                        { contact_details }

    # DescriptionSections_Mapping
    attribute(:DescriptionSections)                   { description_sections }

  private

    def default_description_section_value
      {
        Id: 0,
        Ordinal: 0,
        CourseId: 0,
        Course: nil,
      }
    end

    def description_sections
      [{
        Name: "about this training programme",
        Text: course_enrichment&.about_course,
       },
       {
         Name: "interview process",
         Text: course_enrichment&.interview_process,
       },
       {
         Name: "about fees",
         Text: course_enrichment&.fee_details,
       },
       {
         Name: "about salary",
         Text: course_enrichment&.salary_details,
       },
       {
         Name: "entry requirements",
         Text: course_enrichment&.required_qualifications,
       },
       {
         Name: "entry requirements personal qualities",
         Text: course_enrichment&.personal_qualities,
       },
       {
         Name: "entry requirements other",
         Text: course_enrichment&.other_requirements,
       },
       {
         Name: "financial support",
         Text: course_enrichment&.financial_support,
       },
       {
         Name: "about school placements",
         Text: course_enrichment&.how_school_placements_work,
       },
       {
         Name: "about this training provider",
         Text: object.provider.train_with_us,
       },
       {
         Name: "about this training provider accrediting",
         Text: object.accrediting_provider_description.to_s,
       },
       {
         Name: "training with disabilities",
         Text: object.provider.train_with_disability,
       }].map do |description_section|
        description_section.merge default_description_section_value
      end
    end

    def course_enrichment
      @course_enrichment ||= object.enrichments
                               .select(&:published?)
                               .max_by { |e| [e.created_at, e.id] }
    end

    def provider_external_contact_info
      @provider_external_contact_info ||= object.provider.external_contact_info
    end

    def provider_full_address
      @provider_full_address ||= provider_external_contact_info_full_address
    end

    def duration
      if course_enrichment&.course_length == "OneYear"
        "1 year"
      elsif course_enrichment&.course_length == "TwoYears"
        "Up to 2 years"
      else
        course_enrichment&.course_length
      end
    end

    def fees
      if is_salaried?
        {
          Uk: 0,
          Eu: 0,
          International: 0,
        }
      else
        {
          Uk: course_enrichment&.fee_uk_eu.to_i,
          Eu: course_enrichment&.fee_uk_eu.to_i,
          International: course_enrichment&.fee_international.to_i,
        }
      end
    end

    def contact_details
      external_contact_info = provider_external_contact_info

      {
        **default_contact_details_value,
        Phone: external_contact_info["telephone"],
        Email: external_contact_info["email"],
        Website: external_contact_info["website"],
        Address: provider_full_address,
      }
    end

    def default_contact_details_value
      {
        Id: 0,
        Course: nil,
        Fax: nil,
      }
    end

    def provider_external_contact_info_full_address
      external_contact_info = provider_external_contact_info

      raw_address = { address1: external_contact_info["address1"], address2: external_contact_info["address2"], address3: external_contact_info["address3"], address4: external_contact_info["address4"], postcode: external_contact_info["postcode"] }

      full_address(raw_address)
    end

    def provider_location
      { **default_location_value, Address: provider_full_address }
    end

    def course_subjects
      # CourseSubject_Mapping
      object.syncable_subjects
        .map do |subject|
        {
          **default_course_subjects_value,
          Subject:
            {
              **default_subject_value,
              Name: subject.subject_name,
            },
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
        IsSalaried: is_salaried?,
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
      [address1, address2, address3, address4, postcode].reject(&:blank?).join("\n")
    end

    def campuses_full_address(address1:, address2:, address3:, address4:, postcode:)
      [address1, address2, address3, address4].reject(&:blank?).join(", ") + (postcode.present? ? " " + postcode : "")
    end

    def campuses
      object.findable_site_statuses.map do |site_status|
        raw_address = { address1: site_status.site.address1, address2: site_status.site.address2, address3: site_status.site.address3, address4: site_status.site.address4, postcode: site_status.site.postcode }

        address = campuses_full_address(raw_address)

        {
          **default_campus_value,
          VacStatus: site_status.vac_status_before_type_cast,
          Name: site_status.site.location_name,
          CampusCode: site_status.site.code,
          Location: { **default_location_value, Address: address },
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
        LastGeocodedUtc: "0001-01-01T00:00:00",
      }
    end
  end
end
