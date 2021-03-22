# frozen_string_literal: true

module SupportEmailHelper
  def support_email(name: nil, subject: nil, classes: nil)
    govuk_mail_to(Settings.support_email, name, subject: subject, class: classes)
  end
end
