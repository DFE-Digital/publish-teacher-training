class CourseSubjectsUpdatedEmailMailer < GovukNotifyRails::Mailer
  include TimeFormat

  def course_subjects_updated_email(
    course:,
    previous_subject_names:,
    previous_course_name:,
    recipient:
  )

    set_template(Settings.govuk_notify.course_subjects_updated_email_template_id)

    set_personalisation(
      provider_name: course.provider.provider_name,
      course_code: course.course_code,
      subject_change_datetime: gov_uk_format(course.updated_at),
      course_url: create_course_url(course),
      previous_subjects: format(previous_subject_names),
      updated_subjects: format(course.subjects.map(&:subject_name)),
      previous_course_name: previous_course_name,
      updated_course_name: course.name,
    )

    mail(to: recipient.email)
  end

private

  def format(subject_names)
    if subject_names.length == 1
      subject_names.first
    else
      subject_names.join(", ")
    end
  end

  def create_course_url(course)
    "#{Settings.find_url}" \
      "/course/#{course.provider.provider_code}" \
      "/#{course.course_code}"
  end
end
