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

    # var subjectStrings = ucasCourseData?.CourseSubjects != null
    #     ? subjectMapper.GetSubjectList(ucasCourseData.Name, ucasCourseData.CourseSubjects.Select(x => x.Subject.SubjectName))
    #     : new List<string>();
    def subjects
      # this our filtered list
      object.dfe_subjects
    end

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

    attribute(:HasVacancies)                          { object.has_vacancies? }
    attribute(:IsSen)                                 { object.is_send? }

    # using server time not utc, so it's local time?
    attribute(:StartDate)                             { object.start_date.utc.strftime('%Y-%m-%dT%H:%M:%S') }

    # var subjects = new Collection<SearchAndCompare.Domain.Models.Joins.CourseSubject>(subjectStrings.Select(subject =>
    #     new SearchAndCompare.Domain.Models.Joins.CourseSubject
    #     {
    #         Subject = new SearchAndCompare.Domain.Models.Subject
    #         {
    #             Name = subject
    #         }
    #     }).ToList());
    # var isFurtherEducation = subjects.Any(c =>
    #     c.Subject.Name.Equals("Further education", StringComparison.InvariantCultureIgnoreCase));
    #
    # var provider = new SearchAndCompare.Domain.Models.Provider
    # {
    #     Name = ucasProviderData.ProviderName,
    #     ProviderCode = ucasProviderData.ProviderCode
    # };
    #
    # var accreditingProvider = ucasCourseData.AccreditingProvider == null ? null :
    #     new SearchAndCompare.Domain.Models.Provider
    #     {
    #         Name = ucasCourseData.AccreditingProvider.ProviderName,
    #         ProviderCode = ucasCourseData.AccreditingProvider.ProviderCode
    #     };
    #
    # var routeName = ucasCourseData.Route;
    # var isSalaried = string.Equals(ucasCourseData?.ProgramType, "ss", StringComparison.InvariantCultureIgnoreCase)
    #               || string.Equals(ucasCourseData?.ProgramType, "ta", StringComparison.InvariantCultureIgnoreCase);
    # var fees = courseEnrichmentModel.FeeUkEu.HasValue ? new Fees
    # {
    #     Uk = (int)(courseEnrichmentModel.FeeUkEu ?? 0),
    #     Eu = (int)(courseEnrichmentModel.FeeUkEu ?? 0),
    #     International = (int)(courseEnrichmentModel.FeeInternational ?? 0),
    # } : new Fees();
    #
    # var address = useUcasContact ? MapAddress(ucasProviderData) : MapAddress(providerEnrichmentModel);
    # var mappedCourse = new SearchAndCompare.Domain.Models.Course
    # {
    #     ProviderLocation = new Location { Address = address },
    #     Duration = MapCourseLength(courseEnrichmentModel.CourseLength),

    #     Provider = provider,
    #     AccreditingProvider = accreditingProvider,
    #     Route = new Route
    #     {
    #         Name = routeName,
    #         IsSalaried = isSalaried
    #     },
    #     IncludesPgce = MapQualification(ucasCourseData.Qualification),
    #     HasVacancies = ucasCourseData.HasVacancies,
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
    #     CourseSubjects = subjects,
    #     Fees = fees,

    #     IsSalaried = isSalaried,

    #     ContactDetails = new Contact
    #     {
    #         Phone = useUcasContact ? ucasProviderData.Telephone : providerEnrichmentModel.Telephone,
    #         Email = useUcasContact ? ucasProviderData.Email : providerEnrichmentModel.Email,
    #         Website = useUcasContact ? ucasProviderData.Url : providerEnrichmentModel.Website,
    #         Address = address
    #     },

    #     ApplicationsAcceptedFrom = sites.Select(x => x.ApplicationsAcceptedFrom).Where(x => x.HasValue)
    #         .OrderBy(x => x.Value)
    #         .FirstOrDefault(),
    #




    # mappedCourse.DescriptionSections = new Collection<CourseDescriptionSection>();

    # mappedCourse.DescriptionSections.Add(new CourseDescriptionSection
    # {
    #     //TODO move the CourseDetailsSections constants into SearchAndCompare.Domain.Models
    #     // but this will work ftm
    #     Name = "about this training programme",//CourseDetailsSections.AboutTheCourse,
    #     Text = courseEnrichmentModel.AboutCourse
    # });

    # mappedCourse.DescriptionSections.Add(new CourseDescriptionSection
    # {
    #     Name = "interview process",//CourseDetailsSections.InterviewProcess,
    #     Text = courseEnrichmentModel.InterviewProcess
    # });

    # mappedCourse.DescriptionSections.Add(new CourseDescriptionSection
    # {
    #     Name = "about fees",//CourseDetailsSections.AboutFees,
    #     Text = courseEnrichmentModel.FeeDetails
    # });

    # mappedCourse.DescriptionSections.Add(new CourseDescriptionSection
    # {
    #     Name = "about salary",//CourseDetailsSections.AboutSalary,
    #     Text = courseEnrichmentModel.SalaryDetails
    # });

    # mappedCourse.DescriptionSections.Add(new CourseDescriptionSection
    # {
    #     Name = "entry requirements",//CourseDetailsSections.EntryRequirementsQualifications,
    #     Text = courseEnrichmentModel.Qualifications
    # });

    # mappedCourse.DescriptionSections.Add(new CourseDescriptionSection
    # {
    #     Name = "entry requirements personal qualities",//CourseDetailsSections.EntryRequirementsPersonalQualities,
    #     Text = courseEnrichmentModel.PersonalQualities
    # });

    # mappedCourse.DescriptionSections.Add(new CourseDescriptionSection
    # {
    #     Name = "entry requirements other",//CourseDetailsSections.EntryRequirementsOther,
    #     Text = courseEnrichmentModel.OtherRequirements
    # });

    # mappedCourse.DescriptionSections.Add(new CourseDescriptionSection
    # {
    #     Name = "financial support",//CourseDetailsSections.FinancialSupport,
    #     Text = courseEnrichmentModel.FinancialSupport
    # });

    # mappedCourse.DescriptionSections.Add(new CourseDescriptionSection
    # {
    #     Name = "about school placements",//CourseDetailsSections.AboutSchools,
    #     Text = courseEnrichmentModel.HowSchoolPlacementsWork
    # });

    # mappedCourse.DescriptionSections.Add(new CourseDescriptionSection
    # {
    #     Name = "about this training provider",//CourseDetailsSections.AboutTheProvider,
    #     Text = providerEnrichmentModel.TrainWithUs
    # });

    # mappedCourse.DescriptionSections.Add(new CourseDescriptionSection
    # {
    #     Name = "about this training provider accrediting",//CourseDetailsSections.AboutTheAccreditingProvider,
    #     Text = GetAccreditingProviderEnrichment(ucasCourseData?.AccreditingProvider?.ProviderCode, providerEnrichmentModel)
    # });

    # mappedCourse.DescriptionSections.Add(new CourseDescriptionSection
    # {
    #     Name = "training with disabilities",//CourseDetailsSections.TrainWithDisabilities,
    #     Text = providerEnrichmentModel.TrainWithDisability
    # });
  end
end
