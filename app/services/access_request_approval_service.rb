class AccessRequestApprovalService
  def self.call(access_request)
    new(access_request).call
  end

  def initialize(access_request)
    @access_request = access_request
  end

  def call
    target_user = User.find_or_create_by(email: @access_request.email_address) do |user|
      user.first_name      = @access_request.first_name
      user.last_name       = @access_request.last_name
      user.invite_date_utc = Time.now.utc
    end

    target_user.organisations << @access_request.user.organisations
    @access_request.approve
  end
end
