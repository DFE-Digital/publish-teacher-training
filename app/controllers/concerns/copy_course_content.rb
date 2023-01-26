module CopyCourseContent
  extend ActiveSupport::Concern

private

  def copy_content_check(fields)
    fetch_course_list_to_copy_from

    return if params[:copy_from].blank?

    fetch_course_to_copy_from
    @copied_fields = ::Courses::Copy.get_present_fields_in_source_course(fields, @source_course, @course)
  end

  def copy_boolean_check(fields)
    fetch_course_list_to_copy_from

    return if params[:copy_from].blank?

    fetch_course_to_copy_from
    @copied_fields = ::Courses::Copy.get_boolean_fields(fields, @source_course, @course)
  end

  def fetch_course_to_copy_from
    @source_course = ::Courses::Fetch.by_code(
      provider_code: params[:provider_code],
      course_code: params[:copy_from],
      recruitment_cycle_year: params[:recruitment_cycle_year]
    )
  end

  def fetch_course_list_to_copy_from
    @courses_by_accrediting_provider = ::Courses::Fetch.by_accrediting_provider(@provider)
    @self_accredited_courses = @courses_by_accrediting_provider.delete(@provider.provider_name)

    @courses_by_accrediting_provider&.transform_values! { |v| v.reject { |x| x.id == course.id } }
    @self_accredited_courses = @self_accredited_courses&.reject { |c| c.id == course.id }
  end
end
