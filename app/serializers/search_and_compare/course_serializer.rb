module SearchAndCompare
  class CourseSerializer < ActiveModel::Serializer
    has_one :provider, key: :Provider
    has_one :accrediting_provider, key: :AccreditingProvider



    # ucasProviderData = ucasProviderData ?? new Domain.Models.Provider();
    # ucasCourseData = ucasCourseData ?? new Domain.Models.Course();
    # var sites = ucasCourseData.CourseSites ?? new ObservableCollection<CourseSite>();
    # providerEnrichmentModel = providerEnrichmentModel ?? new ProviderEnrichmentModel();
    def provider_enrichment
      @provider_enrichment ||= object.provider.enrichments.published.by_published_at.last
    end

    # courseEnrichmentModel = courseEnrichmentModel ?? new CourseEnrichmentModel();
    def course_enrichment
      @course_enrichment ||= object.enrichments.published.by_published_at.last
    end

    # var useUcasContact =
    #     string.IsNullOrWhiteSpace(providerEnrichmentModel.Email) &&
    #     string.IsNullOrWhiteSpace(providerEnrichmentModel.Website) &&
    #     string.IsNullOrWhiteSpace(providerEnrichmentModel.Address1) &&
    #     string.IsNullOrWhiteSpace(providerEnrichmentModel.Address2) &&
    #     string.IsNullOrWhiteSpace(providerEnrichmentModel.Address3) &&
    #     string.IsNullOrWhiteSpace(providerEnrichmentModel.Address4) &&
    #     string.IsNullOrWhiteSpace(providerEnrichmentModel.Postcode);
    def use_ucas_contact?
      provider_enrichment.contact_info_present?
    end

    # # var subjectStrings = ucasCourseData?.CourseSubjects != null
    # #     ? subjectMapper.GetSubjectList(ucasCourseData.Name, ucasCourseData.CourseSubjects.Select(x => x.Subject.SubjectName))
    # #     : new List<string>();
    # def subjects
    #   # this is our filtered list
    #   object.dfe_subjects
    # end

    # var isSalaried = string.Equals(ucasCourseData?.ProgramType, "ss", StringComparison.InvariantCultureIgnoreCase)
    #               || string.Equals(ucasCourseData?.ProgramType, "ta", StringComparison.InvariantCultureIgnoreCase);
    def is_salaried?
      !object.is_fee_based?
    end

    ###################################
    # PLACHEHOLDER start              #
    ###################################
    def get_route
      {
        Name: object.program_type,
        IsSalaried: is_salaried?
      }
    end

    # IncludesPgce
    def get_includes_pgce
      [0..4].sample
    end

    # var subjects = new Collection<SearchAndCompare.Domain.Models.Joins.CourseSubject>(subjectStrings.Select(subject =>
    #     new SearchAndCompare.Domain.Models.Joins.CourseSubject
    #     {
    #         Subject = new SearchAndCompare.Domain.Models.Subject
    #         {
    #             Name = subject
    #         }
    #     }).ToList());

    def get_subjects
      object.dfe_subjects.map do |subject|
        {
          CourseId: 0,
          Course: nil,
          SubjectId: 0,
          Subject:        {
            Id: 0,
            SubjectArea: nil,
            FundingId: nil,
            Funding: nil,
            Name: subject.subject_name,
            IsSubjectKnowledgeEnhancementAvailable: false,
            CourseSubjects: nil
          }
        }
      end
    end

    # var fees = courseEnrichmentModel.FeeUkEu.HasValue ? new Fees
    # {
    #     Uk = (int)(courseEnrichmentModel.FeeUkEu ?? 0),
    #     Eu = (int)(courseEnrichmentModel.FeeUkEu ?? 0),
    #     International = (int)(courseEnrichmentModel.FeeInternational ?? 0),
    # } : new Fees();

    def get_fees
    # if the thing is number else 0
      {
          Uk: 0,
          Eu: 0,
          International: 0,
      }
    end

    # why oh why
    # not used
    def get_salary
      {
        Minimum: nil,
        Maximum: nil,
      }
    end

    def get_duration
        # translation keys for 1/2 yrs if there else just use it
      course_length = "OneYear" #enrichment.courseLength;

      if course_length == "OneYear"
        return "1 year"
      elsif course_length == "TwoYears"
        return "Up to 2 years"
      else
        course_length

      end
    end

    def get_mod
      {
        # Lets hope jb's pj coding paid off
        # Possible values
        # "PGCE full time"
        # "PGCE, full time or part time"
        # "PGCE with QTS full time"
        # "PGCE with QTS, full time or part time"
        # "PGCE with QTS, full time or part time with salary"
        # "PGCE with QTS full time teaching apprenticeship"
        # "PGCE with QTS full time with salary"
        # "PGCE with QTS part time"
        # "PGDE full time"
        # "PGDE with QTS full time"
        # "QTS full time"
        # "QTS, full time or part time"
        # "QTS, full time or part time with salary"
        # "QTS full time teaching apprenticeship"
        # "QTS full time with salary"
        # "QTS part time"
        # "QTS part time with salary"

      }
    end

    def contact_details
#           string.IsNullOrWhiteSpace(providerEnrichmentModel.Email) &&
#           string.IsNullOrWhiteSpace(providerEnrichmentModel.Website) &&
#           string.IsNullOrWhiteSpace(providerEnrichmentModel.Address1) &&
#           string.IsNullOrWhiteSpace(providerEnrichmentModel.Address2) &&
#           string.IsNullOrWhiteSpace(providerEnrichmentModel.Address3) &&
#           string.IsNullOrWhiteSpace(providerEnrichmentModel.Address4) &&
# string.IsNullOrWhiteSpace(providerEnrichmentModel.Postcode);

      {
        address1: 'address1',
      address2: 'address2',
      address3: 'address3',
      address4: 'address4',
      postcode: 'postcode',
      phone: 'Telephone',
      email: 'Email',
      website: 'Website',
}
    end

    def get_contact_details
      {
        Id: 0,
        Phone: contact_details[:phone],
        Fax: nil, # need to check
        Email: contact_details[:email],
        Website: contact_details[:website],
        Address: get_provider_address,
        Course: nil
      }
    end

    def get_address(_address_parts_list)
      'address'
    end

    def get_provider_address
      #use_address = contact_details
      address_parts_list = { address1: 'use_address.address1', address2: 'use_address.address2', address3: 'use_address.address3', address4: 'use_address.address4', postcode: 'use_address.postcode' }
      get_address(address_parts_list)
    end

    def get_provider_location
      get_location_mapping(get_provider_address)
    end

    def get_location_mapping(address)
      {
        Id: 0,
        Address: address,
        FormattedAddress: nil,
        GeoAddress: nil,
        Latitude: nil,
        Longitude: nil,
        LastGeocodedUtc: '0001-01-01T00:00:00'
      }
    end
    ###################################
    # PLACHEHOLDER end                #
    ###################################



    #    # Course_default_value_Mapping
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

    attribute(:HasVacancies)                          { object.has_vacancies? }
    attribute(:IsSen)                                 { object.is_send? }

    # using server time not utc, so it's local time?
    attribute(:StartDate)                             { object.start_date.utc.strftime('%Y-%m-%dT%H:%M:%S') }

    attribute(:IsSalaried)                            { is_salaried? }
    attribute(:Route)                                 { get_route }

    # may need '%Y-%m-%dT%H:%M:%S'
    attribute(:ApplicationsAcceptedFrom)              { object.applications_open_from }

    attribute(:IncludesPgce)                          { get_includes_pgce }
    attribute(:CourseSubjects)                        { get_subjects }
    attribute(:Fees)                                  { get_fees }
    attribute(:Salary)                                { get_salary }

    attribute(:ProviderLocation)                      { get_provider_location }
    attribute(:ContactDetails)                        { get_contact_details }


    # var address = useUcasContact ? MapAddress(ucasProviderData) : MapAddress(providerEnrichmentModel);
    # var mappedCourse = new SearchAndCompare.Domain.Models.Course
    # {
    #     ProviderLocation = new Location { Address = address },
    #     Duration = MapCourseLength(courseEnrichmentModel.CourseLength),


    #     IncludesPgce = MapQualification(ucasCourseData.Qualification),
    #     Campuses = new Collection<SearchAndCompare.Domain.Models.Campus>(sites
    #         .Where(school => String.Equals(school.Status, "r", StringComparison.InvariantCultureIgnoreCase) && String.Equals(school.Publish, "y", StringComparison.InvariantCultureIgnoreCase))
    #         .Select(school =>
    #             new SearchAndCompare.Domain.Models.Campus
    #             {
    #                 Name = school.Site.LocationName,
    #                 CampusCode = school.Site.Code,
    #                 Location = new Location
    #                 {
    #                     Address = MapAddress(school.Site)
    #                 },
    #                 VacStatus = school.VacStatus
    #             }
    #         ).ToList()),


    #     ContactDetails = new Contact
    #     {
    #         Phone = useUcasContact ? ucasProviderData.Telephone : providerEnrichmentModel.Telephone,
    #         Email = useUcasContact ? ucasProviderData.Email : providerEnrichmentModel.Email,
    #         Website = useUcasContact ? ucasProviderData.Url : providerEnrichmentModel.Website,
    #         Address = address
    #     },
  end
end
