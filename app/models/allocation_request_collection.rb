class AllocationRequestCollection
  def initialize(courses)
    @requests = requests_from(courses)
  end

  def to_a
    @requests
  end

private

  def requests_from(courses)
    courses
      .includes(:site_statuses, :subjects, provider: :nctl_organisation, accrediting_provider: :nctl_organisation)
      .merge(SiteStatus.not_discontinued)
      .references(:site_statuses)
      .select { |course| course.provider.nctl_organisation.present? } # filter out any courses where the provider isn't mapped across
      .flat_map { |course| requests_for_single_course(course) }
      .uniq
      .sort_by { |request|
        [
          request.requesting_nctl_organisation&.name || "",
          request.partner_nctl_organisation&.name || "",
          request.subject,
        ]
      }
  end

  def requests_for_single_course(course)
    course.allocation_subjects.map do |subject|
      AllocationRequest.new(
        requesting_nctl_organisation: course.provider.nctl_organisation,
        partner_nctl_organisation: course.accrediting_provider&.nctl_organisation,
        subject: subject,
        route: course.program_type,
        course_aim: course.qualification
      )
    end
  end
end
