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
      .select(&:not_discontinued?) # should this also exclude courses from unmapped orgs?
      .flat_map { |course| requests_for_single_course(course) }
      .uniq
      .sort_by { |request|
        [
          request.requesting_nctl_organisation.name,
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
