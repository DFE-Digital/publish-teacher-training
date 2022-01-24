class ApplicationDecorator < Draper::Decorator
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
    {
      published: { text: "Published", colour: "green" },
      withdrawn: { text: "Withdrawn", colour: "red" },
      empty: { text: "Empty", colour: "grey" },
      draft: { text: "Draft", colour: "yellow" },
      published_with_unpublished_changes: { text: "Published&nbsp;*", colour: "green" },
      rolled_over: { text: "Rolled over", colour: "grey" },
    }
  end

  def unpublished_status_hint
    h.tag.span("*&nbsp;Unpublished&nbsp;changes".html_safe, class: "govuk-body-s govuk-!-display-block govuk-!-margin-bottom-0 govuk-!-margin-top-1")
  end
end
