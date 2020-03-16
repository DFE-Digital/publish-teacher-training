class SendWelcomeJob < ApplicationJob
  queue_as :mailer

  def perform(current_user:)
    SendWelcomeEmailService.call(current_user: current_user)
  end
end
