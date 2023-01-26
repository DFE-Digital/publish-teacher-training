# frozen_string_literal: true

class AccessRequestPolicy
  attr_reader :user, :access_request

  def initialize(user, _access_request)
    @user = user
  end

  def approve?
    @user.admin?
  end

  def create?
    @user.present?
  end

  alias new? create?
  alias index? approve?
  alias show? approve?
  alias inform_publisher? approve?
  alias confirm? approve?
  alias destroy? approve?
end
