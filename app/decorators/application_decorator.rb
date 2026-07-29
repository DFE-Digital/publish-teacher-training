# frozen_string_literal: true

class ApplicationDecorator < Draper::Decorator
  # TODO: Move this to a view component
  def status_tag
    h.govuk_tag(text: status_text.html_safe, colour: status_colour)
  end

  def status_text
    return status_tags[:withdrawn][:text] if object.ucas_status == "not_running"

    status_tags[object.content_status.to_sym][:text]
  end

  def status_colour
    return status_tags[:withdrawn][:colour] if object.ucas_status == "not_running"

    status_tags[object.content_status.to_sym][:colour]
  end

  def status_tags
    if current_recruitment_cycle_year? || previous_recruitment_cycle?
      object.application_status_open? ? status_tags_for_vacancies : status_tags_for_no_vacancies
    else
      status_tags_for_rolled_over_courses
    end
  end

private

  def status_tags_for_vacancies
    {
      published: { text: "Open", colour: "teal" },
      withdrawn: { text: "Withdrawn", colour: "red" },
      empty: { text: "Draft", colour: "grey" },
      draft: { text: "Draft", colour: "grey" },
      rolled_over: { text: "Rolled over", colour: "yellow" },
    }
  end

  def status_tags_for_no_vacancies
    status_tags_for_vacancies.merge(published: { text: "Closed", colour: "purple" })
  end

  def status_tags_for_rolled_over_courses
    status_tags_for_vacancies.merge(published: { text: "Scheduled", colour: "blue" })
  end

  def current_recruitment_cycle_year?
    course.in_current_cycle?
  end

  def previous_recruitment_cycle?
    course.recruitment_cycle.year.to_i == Find::CycleTimetable.previous_year
  end
end
