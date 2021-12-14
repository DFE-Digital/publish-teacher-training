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

    orgs_missing_on_target_user = @access_request.requester.organisations - target_user.organisations
    target_user.organisations << orgs_missing_on_target_user

    # In addition, create the user permission relationship
    missing_providers_on_target_user = orgs_missing_on_target_user.flat_map(&:providers)
    missing_providers_on_target_user.each do |org_provider|
      target_user.providers << org_provider
    end

    @access_request.approve
  end
end
