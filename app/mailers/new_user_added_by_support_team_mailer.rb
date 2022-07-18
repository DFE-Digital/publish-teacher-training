class NewUserAddedBySupportTeamMailer < GovukNotifyRails::Mailer
  def user_added_to_provider_email(
    recipient:
  )
    set_template(Settings.govuk_notify.new_user_added_by_support_team_id)

    mail(to: recipient.email)
  end
end
