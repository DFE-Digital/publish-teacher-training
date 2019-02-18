class ProviderPolicy
  attr_reader :user, :provider

  def initialize(user, provider)
    @user = user
    @provider = provider
  end

  def index?
    user.providers.include?(provider)
  end
end
