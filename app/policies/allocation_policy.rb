class AllocationPolicy
  attr_reader :user, :allocation

  def initialize(user, allocation);
    @allocation = allocation
    @user = user
  end

  def create?
    user_belongs_to_the_accredited_body?
  end

private

  def user_belongs_to_the_accredited_body?
    user.providers.include?(allocation.accredited_body)
  end
end
