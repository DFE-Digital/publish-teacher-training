module PublishInterface
  module ViewHelper
    def bat_contact_mail_to(name = nil, **kwargs)
      govuk_mail_to bat_contact_email_address, name || bat_contact_email_address_with_wrap, **kwargs
    end

    def bat_contact_email_address
      Settings.support_email
    end

    def bat_contact_email_address_with_wrap
      # https://developer.mozilla.org/en-US/docs/Web/HTML/Element/wbr
      # The <wbr> element will not be copied when copying and pasting the email address
      bat_contact_email_address.gsub("@", "<wbr>@").html_safe
    end
  end
end
