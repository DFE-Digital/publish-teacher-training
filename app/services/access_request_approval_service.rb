# frozen_string_literal: true

class AccessRequestApprovalService
  def self.call(access_request)
    new(access_request).call
  end

  def initialize(access_request)
    @access_request = access_request
  end

  def call
    target_user = User.find_or_create_by!(email: @access_request.email_address.downcase) do |user|
      user.first_name      = @access_request.first_name
      user.last_name       = @access_request.last_name
      user.invite_date_utc = Time.now.utc
    end

    providers_missing_on_target_user = @access_request.requester.providers - target_user.providers
    target_user.providers << providers_missing_on_target_user

    @access_request.approve
  end
end
