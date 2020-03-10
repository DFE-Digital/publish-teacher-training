module ViewHelper
  def govuk_link_to(body, url = body, html_options = { class: "govuk-link" })
    html_options[:class] = "govuk-link" + (" #{html_options[:class]}" if html_options[:class])
    link_to body, url, html_options
  end
end
