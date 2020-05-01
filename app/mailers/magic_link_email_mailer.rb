class MagicLinkEmailMailer < GovukNotifyRails::Mailer
  def magic_link_email(user)
    set_template(Settings.govuk_notify.magic_link_email_template_id)

    set_personalisation(
      first_name: user.first_name,
      magic_link_url: magic_link_url_for_user(user),
    )

    mail(to: user.email)
  end

private

  def magic_link_url_for_user(user)
    "#{Settings.publish_url}/signin_with_magic_link?email=#{user.email}&token=#{user.magic_link_token}"
  end
end
