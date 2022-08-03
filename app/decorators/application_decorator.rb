class ApplicationDecorator < Draper::Decorator
  # TODO: Move this to a view component
  def status_tag
    tag = h.govuk_tag(text: status_text.html_safe, colour: status_colour)
    tag += unpublished_status_hint if object.has_unpublished_changes?
    tag.html_safe
  end

private

  def status_text
    return status_tags[:withdrawn][:text] if object.ucas_status == "not_running"

    status_tags[object.content_status.to_sym][:text]
  end

  def status_colour
    return status_tags[:withdrawn][:colour] if object.ucas_status == "not_running"

    status_tags[object.content_status.to_sym][:colour]
  end

  def status_tags
    object.has_vacancies? ? status_tags_for_vacancies : status_tags_for_no_vacancies
  end

  def status_tags_for_vacancies
    {
      published: { text: "Open", colour: "turquoise" },
      withdrawn: { text: "Withdrawn", colour: "red" },
      empty: { text: "Empty", colour: "grey" },
      draft: { text: "Draft", colour: "grey" },
      published_with_unpublished_changes: { text: "Open&nbsp;*", colour: "turquoise" },
      rolled_over: { text: "Rolled over", colour: "yellow" },
    }
  end

  def status_tags_for_no_vacancies
    {
      published: { text: "Closed", colour: "purple" },
      withdrawn: { text: "Withdrawn", colour: "red" },
      empty: { text: "Empty", colour: "grey" },
      draft: { text: "Draft", colour: "grey" },
      published_with_unpublished_changes: { text: "Closed&nbsp;*", colour: "purple" },
      rolled_over: { text: "Rolled over", colour: "yellow" },
    }
  end

  def unpublished_status_hint
    h.tag.span("*&nbsp;Unpublished&nbsp;changes".html_safe, class: "govuk-body-s govuk-!-display-block govuk-!-margin-bottom-0 govuk-!-margin-top-1")
  end
end
