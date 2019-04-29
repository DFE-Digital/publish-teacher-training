class AccessRequestApprovalService
  def self.call(access_request)
    new(access_request).call
  end

  def initialize(access_request)
    @access_request = access_request
  end

  def call
    User.create!(
      email: @access_request.email_address,
      first_name: @access_request.first_name,
      last_name: @access_request.last_name,
      invite_date_utc: Time.now.utc,
      organisations: @access_request.user.organisations
    )
  end
end
