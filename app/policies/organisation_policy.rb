class OrganisationPolicy
  attr_reader :user, :accessed_organisation

  def initialize(user, accessed_organisation)
    @user = user
    @accessed_organisation = accessed_organisation
  end

  def add_user?
    @user.admin?
  end

  alias_method :index?, :add_user?
end
