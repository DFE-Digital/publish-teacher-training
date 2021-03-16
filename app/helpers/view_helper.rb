module ViewHelper
  def govuk_link_to(body, url = body, html_options = { class: "govuk-link" })
    link_to body, url, html_options
  end

  def govuk_back_link_to(url)
    govuk_link_to("Back", url, class: "govuk-back-link", data: { qa: "page-back" })
  end

  def bat_contact_email_address
    Settings.service_support.contact_email_address
  end

  def bat_contact_email_address_with_wrap
    # https://developer.mozilla.org/en-US/docs/Web/HTML/Element/wbr
    # The <wbr> element will not be copied when copying and pasting the email address

    bat_contact_email_address.gsub("@", "<wbr>@").html_safe # rubocop: disable Rails/OutputSafety
  end

  def bat_contact_mail_to(name = nil, subject: nil, link_class: "govuk-link", data: nil)
    mail_to bat_contact_email_address, name || bat_contact_email_address, subject: subject, class: link_class, data: data
  end

  def header_environment_class
    "app-header__container--#{Settings.environment.selector_name}"
  end

  def beta_tag_environment_class
    "app-tag--#{Settings.environment.selector_name}"
  end

  def beta_banner_environment_label
    Settings.environment.label
  end
end
