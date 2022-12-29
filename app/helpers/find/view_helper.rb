module Find
  module ViewHelper
    def protect_against_mistakes
      if session[:confirmed_environment_at] && session[:confirmed_environment_at] > 5.minutes.ago
        yield
      else
        govuk_link_to "Confirm environment to make changes", find_confirm_environment_path(from: request.fullpath)
      end
    end

    def permitted_referrer?
      return false if request.referer.blank?

      request.referer.include?(request.host_with_port) ||
        Settings.find_valid_referers.any? { |url| request.referer.start_with?(url) }
    end

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

    def bat_contact_mail_to(name = nil, **kwargs)
      govuk_mail_to bat_contact_email_address, name || bat_contact_email_address_with_wrap, **kwargs
    end
  end
end
