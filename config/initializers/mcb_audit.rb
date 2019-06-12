if ENV['MCB_SETUP_AUDIT_USER'].present?
  require 'mcb'
  require 'mcb/config'

  def verbose(msg)
    Rails.logger.info msg
  end

  MCB.configure_audited_user if MCB.connecting_to_remote_db?
end
